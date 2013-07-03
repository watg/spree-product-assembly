class Spree::LineItemOption < ActiveRecord::Base
  validates :quantity, numericality: true
  validates :price, numericality: true
  validates :variant_id, presence: true


  attr_accessible :line_item_id, :variant_id, :quantity, :price, :currency

  belongs_to :variant
  belongs_to :line_item
end
