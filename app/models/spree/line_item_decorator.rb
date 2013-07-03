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
  
  private
  def set_item_uuid
    options_with_quantity = self.line_item_options.map do |e|
      [e.variant, e.quantity]
    end
    self.item_uuid = self.class.build_item_uuid(self.variant, options_with_quantity)
  end
end
