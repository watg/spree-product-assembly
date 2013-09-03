Spree::LineItem.class_eval do
  
  class << self
    def find_by_order_variant_options(order,variant,options)
      item_uuid = build_item_uuid(variant, options)
      self.where(order_id: order.id, variant_id: variant.id, item_uuid: item_uuid).first
    end

    def build_item_uuid(variant,options_with_qty)
      options_with_qty = [] if options_with_qty.blank?
      uuid = options_with_qty.sort{|a,b| a[0].id < b[0].id}.map do |e|
        "#{e[0].id}-#{e[1]}"
      end
      uuid.unshift(variant.id)
      uuid.join(':')
    end
  end

  has_many :line_item_options, dependent: :destroy

  before_create :set_item_uuid
  attr_accessor :options_with_qty
  
  def add_options(options_with_qty, currency=nil)
    options = options_with_qty.map do |o|
      attrs = {variant_id: o[0].id, quantity: o[1], line_item_id: self.id}
      if currency
        attrs.merge!(price: o[0].kit_price_in(currency).amount, currency: currency)
      else
        attrs.merge!(price: o[0].kit_price)
      end
      Spree::LineItemOption.new(attrs)
    end
    
    self.line_item_options = options
  end

  def single_money
    Spree::Money.new(unitary_price, { currency: currency })
  end

  def unitary_price
    ( line_item_options.blank? ? price : (price + amount_all_options) )
  end
  
  def amount
    unitary_price * quantity
  end

  def amount_without_option
    price * quantity
  end

  def amount_all_options
    list_amount = self.line_item_options.map {|e| e.price * e.quantity}
    list_amount.inject(0){|s,a| s += a; s}
  end

  def sufficient_stock?
    if self.product.can_have_parts?
      kit_sufficient_stock?
    else
      Spree::Stock::Quantifier.new(variant_id).can_supply? quantity
    end
  end

  def required_and_optional_parts
    required_part_list = self.variant.required_parts_for_display
    optional_part_list = self.line_item_options.map do |o|
      v = Spree::Variant.find(o.variant_id)
      v.count_part = o.quantity
      v
    end

    (required_part_list + optional_part_list).flatten
  end

  
  private
  def set_item_uuid
    options_with_quantity = self.line_item_options.map do |e|
      [e.variant, e.quantity]
    end
    self.item_uuid = self.class.build_item_uuid(self.variant, options_with_quantity)
  end

  def kit_sufficient_stock?
    checks = self.variant.required_parts_for_display.map do |part|
      Spree::Stock::Quantifier.new(part.id).can_supply? part.count_part
    end
    checks.inject(true) { |r, bool| r = r && bool; r}     
  end

  #
  # based on product type
  def update_inventory
    # We do not call self.product as when save is called on the line_item object it for some reason
    # causes the product to update due to the has_one through variant relationship
    if variant.product.can_have_parts?
      Spree::OrderInventoryAssembly.new(self).verify(target_shipment)
    else
      Spree::OrderInventory.new(self.order).verify(self, target_shipment)
    end
  end
end
