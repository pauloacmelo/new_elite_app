class Teacher < ActiveRecord::Base
  has_paper_trail
  
  attr_accessible :employee_id, :nickname, :subject_ids,
    :product_group_preferences_attributes, :campus_ids, :morning, :afternoon, :evening, 
    :saturday_moning, :saturday_afternoon, :sunday_morning, :sunday_afternoon, 
    :agree_with_terms, :administrative_job,
    :graduated, :major_id, :institute, :bachelor, :cref, :time_teaching, 
    :post_graduated, :post_graduated_comment, :professional_experiences, 
    :professional_experiences_attributes, :campus_preference_ids

  belongs_to :employee
  belongs_to :major

  has_many :teached_subjects, dependent: :destroy
  has_many :subjects, through: :teached_subjects

  has_many :campus_preferences, dependent: :destroy
  has_many :campuses, through: :campus_preferences

  has_many :product_group_preferences, dependent: :destroy
  accepts_nested_attributes_for :product_group_preferences, 
    reject_if: proc { |attributes| attributes['preference'].blank? }
  has_many :product_preferences, through: :product_group_preferences, class_name: :product

  has_many :periods, dependent: :destroy
  has_many :klazzes, through: :periods
  has_many :product_years, through: :klazzes

  has_many :professional_experiences, dependent: :destroy
  accepts_nested_attributes_for :professional_experiences, allow_destroy: true, reject_if: :all_blank

  validates :employee_id, :nickname, presence: true, on: :update
end
