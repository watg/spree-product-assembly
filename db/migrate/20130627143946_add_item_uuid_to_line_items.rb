class AddItemUuidToLineItems < ActiveRecord::Migration
  def change
    add_column :spree_line_items, :item_uuid, :string
  end
end
