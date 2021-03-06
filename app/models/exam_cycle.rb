class ExamCycle < ActiveRecord::Base
  has_paper_trail
  
  attr_accessible :end_date, :name, :start_date, :product_year_id, :is_bolsao

  belongs_to :product_year
  has_many :exam_days, dependent: :destroy

  validates :name, :product_year_id, presence: true
  validates :name, uniqueness: { scope: :product_year_id }

  def super_klazzes
  	product_year.super_klazzes
  end
end
