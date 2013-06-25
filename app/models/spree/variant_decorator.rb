Spree::Variant.class_eval do
  include Spree::AssembliesPartsCommon

  has_and_belongs_to_many  :assemblies, :class_name => "Spree::Variant",
    :join_table => "spree_assemblies_parts",
    :foreign_key => "part_id", :association_foreign_key => "assembly_id"

  attr_accessible :label, :kit_price

  attr_accessor :count_part, :optional_part

  def can_have_optional_parts?
    false
  end

  has_one :default_price,
  class_name: 'Spree::Price',
  conditions: proc { { currency: Spree::Config[:currency], is_kit: false  }},
  dependent: :destroy
  
  has_one :variant_kit_price,
  class_name: 'Spree::Price',
  conditions: proc { { currency: Spree::Config[:currency], is_kit: true } },
  dependent: :destroy
  
  delegate_belongs_to :variant_kit_price, :kit_price, :kit_price=

  after_save :save_kit_price
    
    
  private
  def save_kit_price
    if variant_kit_price && (variant_kit_price.changed? || variant_kit_price.new_record?)
      variant_kit_price.is_kit= true
      variant_kit_price.save
    end
  end
end
