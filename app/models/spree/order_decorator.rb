Spree::Order.class_eval do

  
  def create_proposed_shipments
    Rails.logger.info "-------------------->>>>>>>>>>>>>>>>>>>>>>>> : Shipment: #{shipments.inspect}"
    shipments.destroy_all
        Rails.logger.info "-------------------->>>>>>>>>>>>>>>>>>>>>>>> : Mann"

    packages = Spree::Stock::Coordinator.new(self).packages
    packages.each do |package|
      shipments << package.to_shipment
    end
    Rails.logger.info "-------------------->>>>>>>>>>>>>>>>>>>>>>>> : Mann"
    shipments
  end

  
end
