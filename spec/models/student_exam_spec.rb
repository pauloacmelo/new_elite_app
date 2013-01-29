require 'spec_helper'

describe 'StudentExam' do
  CARD_PATH = "#{Rails.root}/spec/support/card_b.tif"
  
  it 'initializes a valid student exam' do
    exam = create :exam
    card_type = create :card_type

    student_exam = StudentExam.new(
      exam_id: exam.id, 
      card: File.open(CARD_PATH), 
      card_type_id: card_type.id)

    student_exam.must.be :valid? 
  end

  it 'updates a student exam answers' do
    exam = create :exam
    card_type = create :card_type, student_number_length: 7 
    30.times { create :exam_question, exam_id: exam.id }
    student_exam = create :student_exam, exam_id: exam.id, card_type_id: card_type.id

    student_exam.update_attributes process_result: '1234567ABCDEABCDEABCDEABCDEABCDEABCDE' + 'Z'*70
    ExamAnswer.count.must.equal 30
  end
end
