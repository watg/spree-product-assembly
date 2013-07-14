class Spree::Admin::ProductPartsController < Spree::Admin::PartsController

  private
  def find_item
    @item = Spree::Product.find_by_permalink(params[:product_id])
    @product = @item
  end

  helper do
    def admin_item_parts_url(product)
      admin_product_parts_url(product)
    end

    def set_count_admin_item_part_url(product, part)
       set_count_admin_product_part_url(product, part)
    end

    def remove_admin_item_part_url(product, part)
       remove_admin_product_part_url(product, part)
    end
     
    def admin_item_parts_path(product)
        admin_product_parts_path(product)
    end

    def available_admin_item_parts_url(product)
      available_admin_product_parts_url(product)
    end

  end

end
