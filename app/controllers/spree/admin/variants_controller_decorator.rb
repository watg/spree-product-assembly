Spree::Admin::VariantsController.class_eval do

  def destroy
    @variant = Spree::Variant.find(params[:id])

    if @variant.part? == true
      flash[:error] = Spree.t('notice_messages.variant_is_part_of_an_assembly')
      respond_with(@collection)
    else

      if @variant.destroy
        flash[:success] = Spree.t('notice_messages.variant_deleted')
      else
        flash[:success] = Spree.t('notice_messages.variant_not_deleted')
      end

      respond_with(@variant) do |format|
        format.html { redirect_to admin_product_variants_url(params[:product_id]) }
        format.js  { render_js_for_destroy }
      end
    end
  end
end
