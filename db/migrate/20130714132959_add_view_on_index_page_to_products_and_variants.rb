class AddViewOnIndexPageToProductsAndVariants < ActiveRecord::Migration
  def change
    add_column :spree_products, :view_on_index_page, :boolean, :default => true
    add_column :spree_variants, :view_on_index_page, :boolean, :default => false
  end
end
