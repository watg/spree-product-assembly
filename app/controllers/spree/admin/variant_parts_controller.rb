class Spree::Admin::VariantPartsController < Spree::Admin::PartsController

  private

  # Variant
  def find_item 
      @item = Spree::Variant.find_by_id(params[:variant_id])
      @product = @item.product
  end

  # In a helper
  helper do
    def admin_item_parts_url( variant )
       admin_product_variants_parts_url(variant.product, variant)
    end

    def set_count_admin_item_part_url(variant, part)
       set_count_admin_product_variant_part_url(variant.product, variant, part)
    end

    def remove_admin_item_part_url(variant, part)
       remove_admin_product_variant_part_url(variant.product, variant, part)
    end

    def admin_item_parts_path(variant)
        admin_product_variant_parts_path(variant.product, variant)
    end

    def available_admin_item_parts_url(variant)
      available_admin_product_variant_parts_url(variant.product, variant)
    end

  end

end
