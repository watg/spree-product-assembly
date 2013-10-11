class Spree::Admin::PartsController < Spree::Admin::BaseController
  before_filter :find_item
  respond_to :json

  def index
    @parts_for_display = @item.parts_for_display
  end

  def set_count
    @part = Spree::Variant.find(params[:id])
    @item.set_part_count(@part, qty, optional )
    render 'spree/admin/parts/update_parts_table'
  end

  def available
    if params[:q].blank?
      @available_products = []
    else
      query = "%#{params[:q]}%"
      @available_products = Spree::Product.not_deleted.available.joins(:master).where("(spree_products.name LIKE ? OR spree_variants.sku LIKE ?) AND can_be_part = ? AND product_type = ?", query, query, true, 'product').limit(30)
      
      @available_products.uniq!
    end
    respond_to do |format|
      format.html {render :layout => false}
      format.js {render :layout => false}
    end
  end

  def available_parts
    if params[:q].blank?
      @available_products = []
    else
      query = "%#{params[:q]}%"
      @available_products = Spree::Product.not_deleted.available.joins(:master).where("(spree_products.name LIKE ? OR spree_variants.sku LIKE ?) AND can_be_part = ? AND product_type = ?", query, query, true, 'product').limit(30)
      
      @available_products.uniq!
    end
    @parts = @available_products.map { |p| p.variants }.flatten
  end

  def current
    @parts = []
    @item.parts.each do |p|
      @parts << {
        name: @product.name,
        options_text: p.options_text,
        id: p.id,
      } 
    end
    respond_to do |format|
      format.json do
        render :json => @parts
      end
    end
  end

  def create
    @part = Spree::Variant.find(params[:part_id])
    @item.add_part(@part, qty, optional) if qty > 0
    render 'spree/admin/parts/update_parts_table'
  end

  private

    def find_item
      raise "This method should have been overrided"
    end
    def optional
      params[:part_optional] == "true"
    end
    def qty
      params[:part_count].to_i
    end
end
