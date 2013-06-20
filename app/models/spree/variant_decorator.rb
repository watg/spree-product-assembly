Spree::Variant.class_eval do
  include Spree::AssembliesPartsCommon

  has_and_belongs_to_many  :assemblies, :class_name => "Spree::Variant",
    :join_table => "spree_assemblies_parts",
    :foreign_key => "part_id", :association_foreign_key => "assembly_id"

end
