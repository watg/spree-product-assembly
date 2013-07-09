Spree::OrderContents.class_eval do
  def add(variant, quantity, currency=nil, shipment=nil, options=nil)
    options_with_qty = (options.blank? ? [] : options)
    #get current line item for variant if exists
    line_item = Spree::LineItem.find_by_order_variant_options(order,variant,options_with_qty)
    
    #add variant qty to line_item
    add_to_line_item(line_item, variant, quantity, currency, shipment, options_with_qty)
  end

  private

  def add_to_line_item(line_item, variant, quantity, currency=nil, shipment=nil, options=nil)

    if line_item
      line_item.target_shipment = shipment
      line_item.quantity += quantity
      line_item.currency = currency unless currency.nil?
      line_item.save
    else
      line_item = Spree::LineItem.new(quantity: quantity)
      line_item.target_shipment = shipment
      line_item.variant = variant
      if currency
        line_item.currency = currency unless currency.nil?
        line_item.price    = variant.price_in(currency).amount
        line_item.add_options(options,currency)
      else
        line_item.price    = variant.price
        line_item.add_options(options)
      end
      order.line_items << line_item
      line_item
    end

    order.reload
    line_item
  end

  
end
