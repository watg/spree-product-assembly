class AddDescriptionToVariant < ActiveRecord::Migration
  def change
    add_column :spree_variants, :label, :string
  end
end
