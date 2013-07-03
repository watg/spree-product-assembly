class CreateTableLineItemOptions < ActiveRecord::Migration
  def change
    create_table :spree_line_item_options do |t|
      t.integer :line_item_id,  :null => false
      t.integer :variant_id,    :null => false
      t.integer :quantity,  :null => false
      t.decimal :price,     :precision => 8, :scale => 2, :null => false
      t.string  :currency

      t.timestamps
    end
  end
end
