class StudentExam < ActiveRecord::Base
  has_paper_trail

  BEING_PROCESSED_STATUS = 'Being processed'
  ERROR_STATUS = 'Error'
  STUDENT_NOT_FOUND_STATUS = 'Student not found'
  EXAM_NOT_FOUND_STATUS = 'Exam not found'
  INVALID_ANSWERS_STATUS = 'Invalid answers'
  VALID_STATUS = 'Valid'
  NEEDS_CHECK = [STUDENT_NOT_FOUND_STATUS, EXAM_NOT_FOUND_STATUS, INVALID_ANSWERS_STATUS]

  attr_accessible :card, :card_processing_id, :student_id, :exam_id, :exam_answers_attributes
  delegate :card_type, :is_bolsao, :exam_date, :campuses, to: :card_processing

  belongs_to :exam
  belongs_to :student
  belongs_to :card_processing
  has_many :exam_answers, dependent: :destroy
  accepts_nested_attributes_for :exam_answers

  validates :card, :card_processing_id, :status, presence: true

  mount_uploader :card, StudentExamCardUploader
  after_save :destroy_conflicts!

  before_validation :set_status_to_being_processed, on: :create

  validates_presence_of :student, if: :student_not_found?
  before_update :set_exam, if: :student_not_found?

  validates_presence_of :exam, if: :exam_not_found?
  before_update :set_exam_answers, if: :exam_not_found?

  before_update :set_status_to_valid, if: :invalid_answers?

  def self.needing_check
    where(status: NEEDS_CHECK)
  end

  def needs_check?
    NEEDS_CHECK.include? status
  end

  def possible_students
    campuses.map do |campus|
      campus.possible_students(is_bolsao)
    end.flatten.uniq
  end

  def possible_exams
    student.possible_exams(is_bolsao, exam_date)
  end

  def answers_needing_check
    exam_answers.select{ |ea| ea.need_to_be_checked? }
  end

  def student_not_found?
    status == STUDENT_NOT_FOUND_STATUS
  end

  def exam_not_found?
    status == EXAM_NOT_FOUND_STATUS
  end

  def invalid_answers?
    status == INVALID_ANSWERS_STATUS
  end

  def scan
    begin
      self.student_number, self.string_of_answers = 
        card_type.scan(card.path, card.normalized_path) 
    rescue
      update_attribute :status, ERROR_STATUS
      return
    end

    set_student
    save!
  end

private

  def set_status_to_being_processed
    self.status = BEING_PROCESSED_STATUS
    true
  end

  def set_student
    if is_bolsao
      student = Applicant.where(number: student_number).first.try(:student)
    else
      student = Student.where(ra: student_number).first
    end

    if student and possible_students(campuses, is_bolsao).include?(student) 
      self.student_id = student.id 
      set_exam
    else
      self.status = STUDENT_NOT_FOUND_STATUS
    end
    true
  end

  def set_exam
    exams = possible_exams
    if exams.present? and exams.size == 1
      self.exam_id = exams.first.id
      set_exam_answers
    else
      self.status = EXAM_NOT_FOUND_STATUS
    end
    true
  end 

  def set_exam_answers
    exam_questions = exam.exam_questions.order(:number)
    (0..(exam_questions.size - 1)).each do |i|      
      campuses.map(&:product_years).flatten.uniq.map(&:students)
      exam_answers.build(answer: answers[i], exam_question_id: exam_questions[i].id)
    end
    if answers_needing_check.any?
      self.status = INVALID_ANSWERS_STATUS
    else
      self.status = VALID_STATUS
    end
    true
  end

  def set_status_to_valid
    self.status = VALID_STATUS
    true
  end

  def destroy_conflicts!
    if student.present? and exam.present?
      StudentExam.where(student_id: student.id, exam_id: exam.id).each do |student_exam|
        student_exam.destroy if student_exam.id != self.id
      end
    end
    true
  end
end
