module Spree::AssembliesPartsCommon
  extend ActiveSupport::Concern

  included do
    has_many :assemblies_parts, :as => :assembly
    has_many :parts, :through => :assemblies_parts, :class_name => "Spree::Variant"

    attr_accessor :count_part
    attr_accessible :label
  end

  def assemblies_for(products)
    assemblies.where("spree_assemblies_parts.assembly_id = ?", products)
  end

  def add_part(variant, count = 1)
    ap = Spree::AssembliesPart.get(self.class, self.id, variant.id)
    if ap
      ap.count += count
      ap.save
    else
      self.parts << variant
      set_part_count(variant, count) if count > 1
    end
  end

  def remove_part(variant)
    ap = Spree::AssembliesPart.get(self.class, self.id, variant.id)
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
    ap = Spree::AssembliesPart.get(self.class, self.id, variant.id)
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
    ap = Spree::AssembliesPart.get(self.class, self.id, variant.id)
    ap ? ap.count : 0
  end


  def kit_parts
    parts.map do |p|
      # this is to have the count of the part counted by the variant
      p.count_part = count_of(p)
      p
    end
  end

  def label
    super || product.name
  end

end
