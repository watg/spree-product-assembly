Spree::Price.class_eval do
  alias :kit_price :price
  alias :kit_price= :price=
  attr_accessible :is_kit
end
