Spree::ProductsController.class_eval do
  helper do
    def price_in_pence(obj,currency)
      (obj.price_in(currency).price * 100).to_i
    end
  end

end
