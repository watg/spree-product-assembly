Spree::Price.class_eval do
  alias :kit_price :price
  alias :kit_price= :price=
  alias :display_kit_price :display_price
  attr_accessible :is_kit
end
