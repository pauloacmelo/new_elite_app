require 'spec_helper'

describe 'Exams' do
  before(:each) { log_admin_in }

  it 'shows all exams' do
    5.times { |i| create :exam, name: "Exam#{i}" }

    visit exams_url

    5.times { |i| page.should have_content "Exam#{i}" }
    Exam.count.should == 5 
  end

  it 'creates a exam' do
    create :exam_cycle, name: 'ExamCycle'
    subject = create :subject, name: "Subject"
    topic = create :topic, subject_id: subject.id
    5.times { |i| create :question, stem: "Question#{i}", topic_ids: [topic.id] }

    visit exams_url
    click_link 'New Exam'
    fill_in 'Name', with: 'Exam'
    select 'ExamCycle', from: 'Exam cycle'
    select "Subject", from: 'Subject' 
    5.times { |i| select "Question#{i}", from: 'Questions' }
    click_button 'Create'

    page.should have_content 'Exam was successfully created.'
    Exam.count.should == 1
  end

  it 'updates a exam' do
    exam_cycle = create :exam_cycle, name: 'ExamCycle'
    create :exam, exam_cycle_id: exam_cycle.id

    visit exams_url
    click_link 'Edit'
    fill_in 'Name', with: 'NewExam'
    click_button 'Update'

    page.should have_content 'Exam was successfully updated.'
    Exam.count.should == 1
  end
end