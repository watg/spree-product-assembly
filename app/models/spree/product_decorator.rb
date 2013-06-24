Spree::Product.class_eval do
  include Spree::AssembliesPartsCommon

  has_and_belongs_to_many  :assemblies, :class_name => "Spree::Product",
        :join_table => "spree_assemblies_parts",
        :foreign_key => "part_id", :association_foreign_key => "assembly_id"
  
  scope :individual_saled, where(["spree_products.individual_sale = ?", true])

  scope :active, lambda { |*args|
    not_deleted.individual_saled.available(nil, args.first)
  }

  has_many :optional_parts, :through => :assemblies_parts, :class_name => "Spree::Variant", :conditions => ["spree_assemblies_parts.optional = ?", true], :source => :part

  
  attr_accessible :can_be_part, :individual_sale, :kit, :ready_to_wear
end
