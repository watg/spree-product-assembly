class AddOptionalPartsToAssembly < ActiveRecord::Migration
  def change
    add_column :spree_assemblies_parts, :optional, :boolean, :default => false
  end
end
