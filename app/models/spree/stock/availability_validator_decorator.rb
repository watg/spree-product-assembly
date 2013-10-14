module Spree
  module Stock
    # Overriden from spree core to make it also check for assembly parts stock
    class AvailabilityValidator < ActiveModel::Validator
      def validate(line_item)
        if shipment = line_item.target_shipment
          units = shipment.inventory_units_for(line_item.variant)
          return if units.count > line_item.quantity
          quantity = line_item.quantity - units.count
        else
          quantity = line_item.quantity
        end

        product = line_item.product

        valid = if product.can_have_parts?
          line_item.required_and_optional_parts.each do |part|
            Stock::Quantifier.new(part.id).can_supply?(part.count_part * quantity)
          end
        else
          Stock::Quantifier.new(line_item.variant_id).can_supply? quantity
        end

        unless valid
          variant = line_item.variant
          display_name = %Q{#{variant.name}}
          display_name += %Q{ (#{variant.options_text})} unless variant.options_text.blank?

          line_item.errors[:quantity] << Spree.t(:out_of_stock, :scope => :order_populator, :item => display_name.inspect)
        end
      end
    end
  end
end
