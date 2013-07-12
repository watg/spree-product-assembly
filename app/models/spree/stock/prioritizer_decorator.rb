module Spree
  module Stock
    Prioritizer.class_eval do

      def prioritized_packages
        sort_packages
        adjust_packages
      #  prune_packages
        packages
      end

      
    end
  end
end
