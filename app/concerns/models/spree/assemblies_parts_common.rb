module Spree::AssembliesPartsCommon
  extend ActiveSupport::Concern

  included do
    has_many :assemblies_parts, :as => :assembly
    has_many :parts, :through => :assemblies_parts, :class_name => "Spree::Variant"

    attr_accessible :label
  end

  def required_parts_for_display
    parts_for_display( :optional => false )
  end

  def optional_parts_for_display
    parts_for_display( :optional => true )
  end

  def parts_for_display( options = {} )
     Spree::AssembliesPart.where( {:assembly_type => self.class, :assembly_id => self.id}.merge( options ) ).all.map do |ap|
       p = Spree::Variant.find(ap.part_id)
       p.count_part = ap ? ap.count : 0
       p.removable_part = ap.optional
       p
     end
  end

  def removable(variant)
    ap = Spree::AssembliesPart.get(self.class, self.id, variant.id)
    ap.optional
  end

  def assemblies_for(*products)
    assemblies.where("spree_assemblies_parts.assembly_id in (?)", products)
  end

  def add_part(variant, count = 1, removable = false)
    ap = Spree::AssembliesPart.get(self.class, self.id, variant.id)
    if ap
      ap.count += count
      ap.optional = removable
      ap.save
    else
      self.parts << variant
      set_part_count(variant, count, removable) if count > 1
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

  def set_part_count(variant, count, removable)
    ap = Spree::AssembliesPart.get(self.class, self.id, variant.id)
    unless ap.nil?
      if count > 0
        ap.count = count
        ap.optional = removable
        ap.save
      else
        ap.destroy
      end
    end
  end

  def kit?
    assembly?
  end

  # A kit
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
