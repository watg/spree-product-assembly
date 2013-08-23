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
    currency ||= Spree::Config[:currency] # default to that if none is provided
    
    if line_item
      line_item.target_shipment = shipment
      line_item.quantity       += quantity
      line_item.currency        = currency 
      line_item.save
    else
      line_item = Spree::LineItem.new(quantity: quantity)
      line_item.target_shipment = shipment
      line_item.variant         = variant
      line_item.currency        = currency
      line_item.price           = variant.current_price_in(currency).amount
      if variant.in_sale?
        line_item.in_sale       = variant.in_sale
        line_item.normal_price  = variant.price_normal_in(currency).amount
      end
        
      line_item.add_options(options,currency)
    
      order.line_items << line_item
      line_item
    end

    order.reload
    line_item
  end

  
end
