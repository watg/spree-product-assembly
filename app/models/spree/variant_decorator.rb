Spree::Variant.class_eval do
  include Spree::AssembliesPartsCommon

  has_and_belongs_to_many  :assemblies, :class_name => "Spree::Variant",
    :join_table => "spree_assemblies_parts",
    :foreign_key => "part_id", :association_foreign_key => "assembly_id"


  has_many :optional_parts, :through => :assemblies_parts, :class_name => "Spree::Variant", :conditions => ["spree_assemblies_parts.optional = ?", true], :source => :part
  
  attr_accessor :count_part
  attr_accessible :label
end
