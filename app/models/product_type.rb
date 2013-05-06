class ProductType < ActiveRecord::Base
  
  attr_accessible :name

  has_many :products, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
end
