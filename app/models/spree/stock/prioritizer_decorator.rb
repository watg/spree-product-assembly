module Spree
  module Stock
    Prioritizer.class_eval do

      def prioritized_packages
        Rails.logger.info "-^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"*10
        sort_packages
        adjust_packages
      #  prune_packages
        packages
      end

      
    end
  end
end
