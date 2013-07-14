Spree::Variant.class_eval do
  include Spree::AssembliesPartsCommon

  has_and_belongs_to_many  :assemblies, :class_name => "Spree::Variant",
    :join_table => "spree_assemblies_parts",
    :foreign_key => "part_id", :association_foreign_key => "assembly_id"


  attr_accessible :label, :kit_price, :part_id

  attr_accessor :count_part, :optional_part, :part_id

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
  
  delegate_belongs_to :variant_kit_price, :kit_price, :kit_price=, :display_kit_price

  has_many :prices,
  class_name: 'Spree::Price',
  conditions: {is_kit: false},
  dependent: :destroy
  
  has_many :kit_prices,
  class_name: 'Spree::Price',
  conditions: {is_kit: true},
  dependent: :destroy
  
  after_save :save_kit_price
  after_save :save_parts

  delegate_belongs_to :product, :product_type, :isa_part?, :isa_virtual_product?

  def price_in(currency)
    if variant_price_in(currency).blank?
      if product_price_in(currency).blank?
         Spree::Price.new(variant_id: self.id, currency: currency, is_kit: false)
      else
        product_price_in(currency)
      end
    else
      variant_price_in(currency)
    end
  end
  
  def kit_price_in(currency)
    kit_prices.select{ |price| price.currency == currency }.first || Spree::Price.new(variant_id: self.id, currency: currency, is_kit: true)
  end

  def first_part_id
    first_part = self.parts.first
    if first_part
      first_part.id
    else
      nil
    end
  end
  
  private

  def variant_price_in(currency)
    prices.select{ |price| price.currency == currency }.first
  end

  def product_price_in(currency)
    self.product.master.prices.select{ |price| price.currency == currency }.first
  end
  
  def save_kit_price
    if variant_kit_price
      variant_kit_price.is_kit= true
      variant_kit_price.save
    end
  end

  def save_parts
    if isa_virtual_product? and part_id
      self.assemblies_parts.each { |ap| ap.destroy }
      #part_ids.each do |part_id|
        self.assemblies_parts.create( :part_id => part_id, :optional => false, :count => 1 )
      #end
    end
  end

end
