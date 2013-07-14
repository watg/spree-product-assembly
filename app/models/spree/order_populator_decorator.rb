Spree::OrderPopulator.class_eval do  
  # Parameters can be passed using the following possible
  # parameter configurations:
  #
  # * Single variant/quantity pairing
  # +:variants => { variant_id => quantity }+
  #
  # * Multiple products at once
  # +:products => { product_id => variant_id, product_id =>
  # variant_id }, :quantity => quantity+
  def populate(from_hash)
    options = extract_kit_options(from_hash)
    from_hash[:products].each do |product_id,variant_id|
      attempt_cart_add(variant_id, from_hash[:quantity], options)
    end if from_hash[:products]
    
    from_hash[:variants].each do |variant_id, quantity|
      attempt_cart_add(variant_id, quantity)
    end if from_hash[:variants]

    valid?
  end

  private
  def extract_kit_options(hash)
    value = hash[:products].delete(:options) rescue nil
    (value || [])
  end
  
  def attempt_cart_add(variant_id, quantity, option_ids=[])
    quantity = quantity.to_i
    # 2,147,483,647 is crazy.
    # See issue #2695.
    if quantity > 2_147_483_647
      errors.add(:base, Spree.t(:please_enter_reasonable_quantity, :scope => :order_populator))
      return false
    end
    variant, options  = [Spree::Variant.find(variant_id), Spree::Variant.find(option_ids)]
    options = add_quantity_for_each_option(variant, options)

    if quantity > 0
      if check_stock_levels_for_variant_and_options(variant, quantity, options)
        shipment = nil
        @order.contents.add(variant, quantity, currency, shipment, options)
      end
    end
  end
  
  def check_stock_levels_for_variant_and_options(variant, quantity, options=[])
    variant_check, options_check = [[],[]]
    
    if variant.product.can_have_parts?
      # Check stock for required parts
      variant_check = variant.parts_for_display.map do |e|
        check_stock_levels(e, e.count_part)
      end

      # Check stock for optional parts
      options_check = options.map do |e|
        check_stock_levels(e[0], e[1])
      end      
    else
      variant_check = [check_stock_levels(variant, quantity)]
    end
    is_all_stock_levels_ok?(variant_check, options_check)
  end

  def add_quantity_for_each_option(variant, options)
    options.map do |o|
      [o, part_quantity(variant,o)]
    end
  end

  def part_quantity(variant, option)
    variant.product.optional_parts_for_display.detect{|e| e.id = option.id}.count_part
  end

  def is_all_stock_levels_ok?(variant, options)
    (variant + options).inject(true) { |r, bool| r = r && bool; r}
  end
end
