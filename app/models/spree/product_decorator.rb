Spree::Product.class_eval do
  include Spree::AssembliesPartsCommon

  has_and_belongs_to_many  :assemblies, :class_name => "Spree::Product",
        :join_table => "spree_assemblies_parts",
        :foreign_key => "part_id", :association_foreign_key => "assembly_id"
  
  scope :individual_saled, where(["spree_products.individual_sale = ?", true])


  scope :active, lambda { |*args|
    not_deleted.individual_saled.available(nil, args.first)
  }

  delegate_belongs_to :master, :kit_price
  attr_accessible :can_be_part, :individual_sale, :product_type, :kit_price, :view_on_index_page

  TYPES = [ :kit, :product, :virtual_product ]

  def isa_part?
    product_type.to_sym == :product && can_be_part == true 
  end

  def isa_product?
    product_type.to_sym == :product
  end

  def isa_virtual_product?
    product_type.to_sym == :virtual_product
  end

  def isa_kit?
    product_type.to_sym == :kit
  end

  def can_have_optional_parts?
    true
  end

  def can_have_parts?
    isa_kit? or isa_virtual_product?
  end

  private
  # Builds variants from a hash of option types & values
  def build_variants_from_option_values_hash
    ensure_option_types_exist_for_values_hash
    values = option_values_hash.values
    values = values.inject(values.shift) { |memo, value| memo.product(value).map(&:flatten) }

    values.each do |ids|
      attrs = { option_value_ids: ids, price: master.price, label: master.name }
      attrs.merge!(kit_price: master.kit_price) if master.kit_price
      variant = variants.create(attrs, without_protection: true)
    end
    save
  end

  def set_master_variant_defaults
    master.label = self.name
    master.is_master = true
  end  
  
end
