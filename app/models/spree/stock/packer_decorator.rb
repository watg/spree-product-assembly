module Spree
  module Stock
    Packer.class_eval do
      # Overriden from Spree core to build a custom package instead of the
      # default_package built in Spree
      def packages
        if splitters.empty?
          [product_assembly_package]
        else
          build_splitter.split [product_assembly_package]
        end
      end

      # Returns a package with all products and parts from give stock location
      #
      # Follows the same logic as `Packer#default_package` except that it also
      # loops through associated product parts (which is really just another
      # product / variant) to include them on the package if available
      def product_assembly_package
        package = Package.new(stock_location, order)
        order.line_items.each do |line_item|
          next unless stock_location.stock_item(line_item.variant)

          is_an_assembly = line_item.product.assembly?
          on_hand, backordered = stock_location.fill_status(line_item.variant, line_item.quantity)

          if is_an_assembly
            quantity = (backordered > 0 ? backordered : on_hand)
            package.add( line_item.variant, quantity, :on_hand) 
          else
            package.add line_item.variant, on_hand, :on_hand if on_hand > 0
            package.add line_item.variant, backordered, :backordered if backordered > 0
          end
          
          if is_an_assembly
            line_item.required_and_optional_parts.each do |part|
              next unless stock_location.stock_item(part)
              
              on_hand, backordered = stock_location.fill_status(part, (line_item.quantity * part.count_part))
              package.add( part, on_hand, :on_hand) if on_hand > 0
              package.add( part, backordered, :backordered) if backordered > 0
            end
          end
         end

        package
      end
    end
  end
end
