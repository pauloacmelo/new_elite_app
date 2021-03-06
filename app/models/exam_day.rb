class ExamDay < ActiveRecord::Base
  has_paper_trail

  attr_accessible :exam_cycle_id, :super_klazz_id, :super_exam_id, :datetime

  belongs_to :exam_cycle
  belongs_to :super_klazz
  belongs_to :super_exam 
  has_many :student_exams, dependent: :destroy

  validates :datetime, :exam_cycle, :super_klazz, :super_exam, presence: :true 

  def name
    exam_cycle.name + ' - ' + super_klazz.name + ' - ' + datetime.strftime('%d/%m/%Y')
  end
end 