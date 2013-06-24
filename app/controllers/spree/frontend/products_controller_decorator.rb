Spree::ProductsController.class_eval do
  helper do
    def price_in_pence(obj,currency)
      qty = obj.respond_to?(:count_part) ? obj.count_part : 1
      (obj.price_in(currency).price * 100 * qty ).to_i
    end
  end

end
