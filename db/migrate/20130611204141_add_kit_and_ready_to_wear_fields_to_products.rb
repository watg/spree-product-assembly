class AddKitAndReadyToWearFieldsToProducts < ActiveRecord::Migration
  def self.up
    table = if table_exists?(:products)
      'products'
    elsif table_exists?(:spree_products)
      'spree_products'
    end 
    
    change_table(table) do |t|
      t.column :product_type, :string, :limit =>32 , :null => false, :default => Spree::Product::PRODUCT_TYPES.first 
    end  
  end

  def self.down
    table = if table_exists?(:products)
      'products'
    elsif table_exists?(:spree_products)
      'spree_products'
    end 
    
    change_table(table) do |t|
      t.remove :product_type
    end
  end
end
