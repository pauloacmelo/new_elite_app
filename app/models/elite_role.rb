class EliteRole < ActiveRecord::Base

  attr_accessible :name, :school_role_id

  belongs_to :school_role
  has_many :employees

  validates :name, :school_role_id, presence: true
  validates :name, uniqueness: true
end
