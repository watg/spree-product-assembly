module Spree
  # This class has basically the same functionality of Spree core OrderInventory
  # except that it takes account of bundle parts and properly creates and removes
  # inventory unit for each parts of a bundle
  #
  # TODO A lot of code here could be removed to avoid duplicated logic once we
  # improve spree core OrderInventory API. Then we could just inherit from
  # that class and only override what's needed for the specs of this extension
  # e.g. `verify`, `inventory_units` and `remove`

  class OrderInventoryAssembly
    attr_reader :order, :line_item, :product

    def initialize(line_item)
      @order = line_item.order
      @line_item = line_item
      @product = line_item.product
    end

    def verify(line_item, shipment = nil)
      Rails.logger.info ">>>>>>>>>>>>: Calling verify from OrderInventoryAssembly"
      if order.completed? || shipment.present?
        options = line_item.line_item_options.map do |o|
          Rails.logger.info "------------------->>>>>>>>>>>>>>>>>>>>>>>>>>> Checking line_item options #{o.inspect}"
          variant = o.variant
          variant.count_part = o.quantity
          variant
        end

        parts = line_item.variant.required_parts_for_display
        
        parts_and_options = (parts + options).flatten

        Rails.logger.info "------------------->>>>>>>>>>>>>>>>>>>>>>>>>>> ABOUT TO ADD PARTS OF KITS"
        parts_and_options.each do |variant|
          quantity = variant.count_part
          Rails.logger.info ">>>>>>>>>>>>: variant : #{variant.inspect} count: #{quantity}"
          variant_units = inventory_units_for(variant)
          
          if variant_units.size < quantity
            quantity = quantity - variant_units.size
            
            shipment = determine_target_shipment(variant) unless shipment
            Rails.logger.info "------------------->>>>>>>>>>>>>>>>>>>>>>>>>>> Adding ship: #{shipment.inspect} -- variant #{variant.inspect} -- qty #{quantity}"
            add_to_shipment(shipment, variant, quantity)
          elsif variant_units.size > quantity
            Rails.logger.info "------------------->>>>>>>>>>>>>>>>>>>>>>>>>>> REMOVE ship: #{shipment.inspect} -- variant #{variant.inspect} -- qty #{quantity}"
            remove(variant, quantity, variant_units, shipment)
          end
        end
        
      else
        Rails.logger.info "--------------------------------------->>>>>>>>>>>>: [OrderInventoryAssembly]: verify returns true"
        true
      end
    end
    
    def inventory_units_for(variant)
      units = order.shipments.collect{|s| s.inventory_units.all}.flatten
      units.group_by(&:variant_id)[variant.id] || []
    end
    
    private
    def remove(variant, variant_quantity, variant_units, shipment = nil)
      quantity = variant_units.size - variant_quantity

      if shipment.present?
        remove_from_shipment(shipment, variant, quantity)
      else
        order.shipments.each do |shipment|
          break if quantity == 0
          quantity -= remove_from_shipment(shipment, variant, quantity)
        end
      end
    end

    # Returns either one of the shipment:
    #
    # first unshipped that already includes this variant
    # first unshipped that's leaving from a stock_location that stocks this variant
    #
    def determine_target_shipment(variant)
      Rails.logger.info ">>>>>>>>>>>>: Calling determine_target_shipment from OrderInventoryAssembly variant #{variant.inspect}"
      shipment = order.shipments.detect do |shipment|
        (shipment.ready? || shipment.pending?) && shipment.include?(variant)
      end

      shipment ||= order.shipments.detect do |shipment|
        (shipment.ready? || shipment.pending?) && variant.stock_location_ids.include?(shipment.stock_location_id)
      end
    end

    def add_to_shipment(shipment, variant, quantity)
      #create inventory_units
      on_hand, back_order = shipment.stock_location.fill_status(variant, quantity)

      on_hand.times do
        shipment.inventory_units.create(variant_id: variant.id,
                                          state: 'on_hand')
      end

      back_order.times do
        shipment.inventory_units.create(variant_id: variant.id,
                                          state: 'backordered')
      end


      # adding to this shipment, and removing from stock_location
      shipment.stock_location.unstock variant, quantity, shipment

      # return quantity added
      quantity
    end

    def remove_from_shipment(shipment, variant, quantity)
      return 0 if quantity == 0 || shipment.shipped?

      shipment_units = shipment.inventory_units_for(variant).reject do |variant_unit|
        variant_unit.state == 'shipped'
      end.sort_by(&:state)

      removed_quantity = 0

      shipment_units.each do |inventory_unit|
        break if removed_quantity == quantity
        inventory_unit.destroy
        removed_quantity += 1
      end

      if shipment.inventory_units.count == 0
        shipment.destroy
      end

      # removing this from shipment, and adding to stock_location
      shipment.stock_location.restock variant, removed_quantity, shipment

      # return quantity removed
      removed_quantity
    end

  end
end
