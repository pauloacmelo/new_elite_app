class Product < ActiveRecord::Base
  has_paper_trail
  
  attr_accessible :product_type_id, :product_group_id, :name, :prefix, :suffix, :code

  belongs_to :product_type
  belongs_to :product_group

  has_many :product_years, dependent: :destroy
  has_many :klazzes, through: :product_years
  has_many :campuses, through: :klazzes
  has_many :periods, through: :klazzes

  has_many :product_head_teacher_products, dependent: :destroy
  has_many :product_head_teachers, through: :product_head_teacher_products

  has_many :campus_head_teacher_products, dependent: :destroy
  has_many :campus_head_teachers, through: :campus_head_teacher_products

  has_many :subject_head_teacher_products, dependent: :destroy
  has_many :subject_head_teachers, through: :subject_head_teacher_products

  has_many :preferred_products, dependent: :destroy
  has_many :teachers, through: :preferred_products

  validates :product_type_id, :name, :code, presence: true
  validates :name, uniqueness: { scope: :product_type_id }
end
