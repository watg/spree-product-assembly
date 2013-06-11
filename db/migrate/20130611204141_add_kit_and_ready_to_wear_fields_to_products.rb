class AddKitAndReadyToWearFieldsToProducts < ActiveRecord::Migration
  def self.up
    table = if table_exists?(:products)
      'products'
    elsif table_exists?(:spree_products)
      'spree_products'
    end 
    
    change_table(table) do |t|
      t.column :kit, :boolean, :default => false, :null => false
      t.column :ready_to_wear, :boolean, :default => false, :null => false
    end  
  end

  def self.down
    table = if table_exists?(:products)
      'products'
    elsif table_exists?(:spree_products)
      'spree_products'
    end 
    
    change_table(table) do |t|
      t.remove :kit
      t.remove :ready_to_wear
    end
  end
end
