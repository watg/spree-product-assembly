Deface::Override.new(:virtual_path => "spree/orders/_line_item",
                     :name => "product_assembly_cart_item_description",
                     :replace => "[data-hook='cart_item_description']",
                     #:partial => "spree/orders/cart_description",
                     :text => "text"
                     :disabled => false)
