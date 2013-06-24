Spree::Product.class_eval do
  has_and_belongs_to_many  :assemblies, :class_name => "Spree::Product",
        :join_table => "spree_assemblies_parts",
        :foreign_key => "part_id", :association_foreign_key => "assembly_id"
  
  #has_and_belongs_to_many  :parts, :class_name => "Spree::Variant",
  #      :join_table => "spree_assemblies_parts",
  #      :foreign_key => "assembly_id", :association_foreign_key => "part_id"

  has_many :assemblies_parts, :as => :assembly
  has_many :parts, :through => :assemblies_parts, :class_name => "Spree::Variant"

  scope :individual_saled, where(["spree_products.individual_sale = ?", true])

  scope :active, lambda { |*args|
    not_deleted.individual_saled.available(nil, args.first)
  }

  has_many :optional_parts, :through => :assemblies_parts, :class_name => "Spree::Variant", :conditions => ["spree_assemblies_parts.optional = ?", true], :source => :part

  
  attr_accessible :can_be_part, :individual_sale, :kit, :ready_to_wear

  attr_accessor :count_part
  
  def add_part(variant, count = 1)
    ap = Spree::AssembliesPart.get(self.id, variant.id)
    if ap
      ap.count += count
      ap.save
    else
      self.parts << variant
      set_part_count(variant, count) if count > 1
    end
  end

  def remove_part(variant)
    ap = Spree::AssembliesPart.get(self.id, variant.id)
    unless ap.nil?
      ap.count -= 1
      if ap.count > 0
        ap.save
      else
        ap.destroy
      end
    end
  end

  def set_part_count(variant, count)
    ap = Spree::AssembliesPart.get(self.id, variant.id)
    unless ap.nil?
      if count > 0
        ap.count = count
        ap.save
      else
        ap.destroy
      end
    end
  end

  def assembly?
    parts.present?
  end

  def part?
    assemblies.present?
  end

  def count_of(variant)
    ap = Spree::AssembliesPart.get(self.id, variant.id)
    ap ? ap.count : 0
  end

  def kit_parts
    parts.map do |p|
      # this is to have the count of the part counted by the variant
      p.count_part = count_of(p)

      # old data structure
      # {count: count_of(p), id: p.id, text: p.name, sellable: p.product.individual_sale?}
      p
    end
  end

end
