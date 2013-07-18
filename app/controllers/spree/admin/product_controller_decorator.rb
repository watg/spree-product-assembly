Spree::Admin::ProductsController.class_eval do
 
  def destroy
    @product = Product.find_by_permalink!(params[:id])
    if @product.variants_including_master.detect { |v| v.part? == true }
      flash[:error] = Spree.t('notice_messages.product_is_part_of_an_assembly')
      respond_with(@collection)
    else
      @product.destroy
      flash[:success] = Spree.t('notice_messages.product_deleted')

      respond_with(@product) do |format|
        format.html { redirect_to collection_url }
        format.js  { render_js_for_destroy }
      end
    end
  end

end
