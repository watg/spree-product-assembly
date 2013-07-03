module Spree
  module Stock
    AvailabilityValidator.class_eval do

      def validate(line_item)
        unless validate_variant(line_item.variant_id, line_item.quantity)
          line_item.errors[:quantity] << I18n.t('validation.exceeds_available_stock')
        end
        return false unless line_item.errors[:quantity].blank?
        line_item.line_item_options.each do |option|
          unless validate_variant(option.variant_id, option.quantity)
            line_item.errors[:quantity] << I18n.t('validation.exceeds_available_stock')
          end
        end
      end
      
      private
      def validate_variant(variant_id, quantity)
        quantifier = Stock::Quantifier.new(variant_id)
        quantifier.can_supply?(quantity)
      end
    end
  end
end
