Spree::ProductsController.class_eval do
  
  helper do
    def item_quantity(obj)
      obj.respond_to?(:count_part) ? obj.count_part : 1
    end
    def price_in_pence(obj,currency)
      method = (obj.is_master ? :price_in : :kit_price_in)
      price = obj.send(method, currency).price || 0
      ( price * 100 * item_quantity(obj) ).to_i
    end
    def currency_symbol(string)
      string[0]
    end
  end

end
