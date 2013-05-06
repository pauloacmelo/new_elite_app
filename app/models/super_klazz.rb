class SuperKlazz < ActiveRecord::Base
  
  attr_accessible :campus_id, :product_year_id

  belongs_to :campus
  belongs_to :product_year
  has_many :klazzes, dependent: :destroy

  has_many :exam_executions, dependent: :destroy
  has_many :student_exams, through: :exam_executions

  has_many :enrollments, dependent: :destroy
  has_many :enrolled_students, through: :enrollments, source: :student

  has_many :applicants, dependent: :destroy
  has_many :applicant_students, through: :applicants, source: :student

  validates :campus, :product_year, presence: true
  validates :product_year_id, uniqueness: { scope: :campus_id }
  
  def name
    label_method
  end
  
  def label_method
    product_year.name + ' - ' + campus.name
  end

  def product_year_name
    product_year.name
  end
end
