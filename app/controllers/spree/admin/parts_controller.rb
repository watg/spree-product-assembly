class Spree::Admin::PartsController < Spree::Admin::BaseController
  before_filter :find_item

  def index
    @parts_for_display = @item.parts_for_display
  end

  def remove
    @part = Spree::Variant.find(params[:id])
    @item.remove_part(@part)
    render 'spree/admin/parts/update_parts_table'
  end

  def set_count
    @part = Spree::Variant.find(params[:id])
    removable = params[:part_removable] == "true" 
    @item.set_part_count(@part, params[:part_count].to_i, removable )
    render 'spree/admin/parts/update_parts_table'
  end

  def available
    if params[:q].blank?
      @available_products = []
    else
      query = "%#{params[:q]}%"
      @available_products = Spree::Product.not_deleted.available.joins(:master).where("(spree_products.name #{LIKE} ? OR spree_variants.sku #{LIKE} ?) AND can_be_part = ?", query, query, true).limit(30)
      
      @available_products.uniq!
    end
    respond_to do |format|
      format.html {render :layout => false}
      format.js {render :layout => false}
    end
  end

  def create
    @part = Spree::Variant.find(params[:part_id])
    qty = params[:part_count].to_i
    removable = params[:part_removable] == "true" 
    @item.add_part(@part, qty, removable) if qty > 0
    render 'spree/admin/parts/update_parts_table'
  end

  private

    def find_item
      raise "This method should have been overrided"
    end
end
