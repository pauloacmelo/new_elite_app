class Student < ActiveRecord::Base
  has_paper_trail
  
  attr_accessible :email, :name, :password_digest, :ra, :gender,
    :cpf, :own_cpf, :rg, :rg_expeditor, :date_of_birth, :number_of_children, 
    :mother_name, :father_name, :telephone, :cellphone, :previous_school,
    :address_attributes, :applied_super_klazz_ids, :enrolled_super_klazz_ids

  has_many :enrollments, dependent: :destroy, inverse_of: :student
  has_many :enrolled_super_klazzes, through: :enrollments, source: :super_klazz
  has_many :enrolled_exam_days, through: :enrolled_super_klazzes, source: :exam_days
  has_many :enrolled_exams, through: :enrolled_exam_days, source: :exam

  has_many :applicants, dependent: :destroy, inverse_of: :student
  has_many :applied_super_klazzes, through: :applicants, source: :super_klazz
  has_many :applied_exam_days, through: :applied_super_klazzes, source: :exam_days
  has_many :applied_exams, through: :applied_exam_cycles, source: :exam

  has_many :student_exams, dependent: :destroy
  has_many :exams, through: :student_exams

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address

  validates :name, presence: true
  validates :email, :ra, uniqueness: true, allow_blank: true

  def possible_exam_days(is_bolsao, exam_date)
    (is_bolsao ? applied_exam_days : enrolled_exam_days).
      where(datetime: (exam_date.beginning_of_day)..(exam_date.end_of_day))
  end

  def self.create_temporary_student!(name, super_klazz_id)
    super_klazz = SuperKlazz.find(super_klazz_id)

    min_temporary_ra = '9' + super_klazz.campus.code + super_klazz.product_year.product.code + '00'
    min_temporary_ra = min_temporary_ra.to_i - 1
    max_ra = super_klazz.enrolled_students.maximum(:ra)
    ra = 0
    if max_ra.nil?
      ra = min_temporary_ra.to_i
    else
      ra = [max_ra, min_temporary_ra.to_i].max
    end
    ra = ra + 1
    while Student.where(ra: ra).size > 0
      ra = ra + 1  
    end

    student = Student.new
    student.name = name
    student.ra = ra
    student.enrolled_super_klazz_ids = [super_klazz_id]
    student.save!
    student
  end
end
