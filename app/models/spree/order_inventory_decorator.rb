Spree::OrderInventory.class_eval do

  def verify(line_item, shipment = nil)
    if order.completed? || shipment.present?

      variant_units = inventory_units_for(line_item.variant)

      if variant_units.size < line_item.quantity
        quantity = line_item.quantity - variant_units.size

        shipment = determine_target_shipment(line_item.variant) unless shipment
        add_to_shipment(shipment, line_item.variant, quantity)
      elsif variant_units.size > line_item.quantity
        remove(line_item, variant_units, shipment)
      end
    else
      true
    end
  end
  
end
   
