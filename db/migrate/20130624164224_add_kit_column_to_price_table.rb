class AddKitColumnToPriceTable < ActiveRecord::Migration
  def change
    add_column :spree_prices, :is_kit, :boolean, :default => false
  end
end
