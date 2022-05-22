class Product < ActiveRecord::Base
  include MultiStepModel

  has_many :categories
  accepts_nested_attributes_for :categories

  # MultiStepModel
  has_steps 3
  step_1_attributes :name, :description
  step_2_attributes :price, :quantity, categories: [:name, :id]

  # Another way to define step attribuets:
  step_attributes 3, :tags, :available_at

  # Step validations
  validates :name, presence: true, if: :step1?
  validates :quantity, numericality: true, if: :step2?
  validates :tags, presence: true, if: :step3?

end
