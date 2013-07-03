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
     self.assemblies_parts.where( options ).all.map do |ap|
       p = Spree::Variant.find(ap.part_id)
       p.count_part = ap ? ap.count : 0
       p.optional_part = ap.optional
       p
     end
  end

  def assemblies_for(*products)
    assemblies.where("spree_assemblies_parts.assembly_id in (?)", products)
  end

  def add_part(variant, count = 1, optional = false)
    ap = self.assemblies_parts.find_by_part_id( variant.id )
    if ap
      ap.count += count
      ap.optional = optional
      ap.save
    else
      self.assemblies_parts.create( :part_id => variant.id, :optional => optional, :count => count )
    end
  end

  def set_part_count(variant, count, optional)
    ap = self.assemblies_parts.find_by_part_id( variant.id )
    unless ap.nil?
      if count > 0
        ap.count = count
        ap.optional = optional
        ap.save
      else
        ap.delete
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
    ap = self.assemblies_parts.find_by_part_id( variant.id )
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
