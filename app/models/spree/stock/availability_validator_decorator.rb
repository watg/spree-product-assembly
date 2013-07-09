module Spree
  module Stock
    AvailabilityValidator.class_eval do

      def validate(line_item)
        variant = Spree::Variant.find(line_item.variant_id)
        method = (variant.product.isa_kit? ? :validate_kit : :validate_product)

        send(method, line_item, variant)        
      end
      
      private
      def validate_kit(line_item, variant)
        line_item.required_and_optional_parts.each &validator(line_item) 
      end

      
      def validate_product(line_item, variant)
        quantifier = Stock::Quantifier.new(line_item.variant_id)

        unless quantifier.can_supply? line_item.quantity
          line_item.errors[:quantity] << I18n.t('validation.exceeds_available_stock')
        end
        
      end
      
      def validate_variant(variant_id, quantity)
        quantifier = Stock::Quantifier.new(variant_id)
        quantifier.can_supply?(quantity)
      end

      def validator(line_item)
        lambda do |part|
          unless validate_variant(part.id, (line_item.quantity * part.count_part))
            line_item.errors[:quantity] << I18n.t('validation.exceeds_available_stock')
          end
        end
      end
      
    end
  end
end
