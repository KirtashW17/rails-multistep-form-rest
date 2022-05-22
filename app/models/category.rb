class Category < ActiveRecord::Base
  belongs_to :product

  validates :name, presence: true, if: Proc.new {|c| c.product.step2?}

end
