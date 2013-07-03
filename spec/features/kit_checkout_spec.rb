require 'spec_helper'

describe "Kit Checkout" do
  let(:country) { create(:country,
                          :name => "United States",
                          :states_required => true) }
  let(:state) { create(:state, :name => "Ohio", :country => country) }
  let(:shipping_method) { create(:shipping_method) }
  let(:stock_location) { create(:stock_location) }
  let(:payment_method) { create(:payment_method) }
  let(:zone) { create(:zone) }

  let!(:needle) { create(:product,
                        product_type: :part,
                        price: 10,
                        kit_price: 7,
                        name: "Needles") }
  let(:wool) { create(:product,
                      product_type: :part,
                      price: 15,
                      kit_price: 12,
                      name: "Wool") }
  let(:tala_tank_kit) { create(:product,
                               product_type: :kit,
                               price: 45,
                               name: "Tala Tank") }
  
  let(:tala_tank_kit_variant) { create(:variant, product: tala_tank_kit) }

  stub_authorization!


  shared_context "ops creates a kit with optional parts" do
    before do
      add_optional_part_to(tala_tank_kit)
      add_required_part_to(tala_tank_kit, tala_tank_kit_variant)
    end
  end

  shared_context "customer purchase a kit with options" do
    before do
      visit spree.product_path(tala_tank_kit)

      check(needle.name)
      click_button "add-to-cart-button"
      click_button "Checkout"

      fill_in "order_email", :with => "queen@royal.co.uk"
      fill_in_address

      click_button "Save and Continue"
      expect(current_path).to eql(spree.checkout_state_path("delivery"))
      page.should have_content(tala_tank_kit.name)

      click_button "Save and Continue"
      # TODO: check amount to be paid
      # should be kit (price + (option @ kit_price * opt_qty)) * qty
      expect(current_path).to eql(spree.checkout_state_path("payment"))

      click_button "Save and Continue"
      expect(current_path).to eql(spree.order_path(Spree::Order.last))
      page.should have_content(tala_tank_kit.name)
    end
  end

  context "backend should have", js: true do
    include_context "ops creates a kit with optional parts"
    include_context "customer purchase a kit with options"
    
    it "views parts bundled as well" do
      visit spree.admin_orders_path
      click_on Spree::Order.last.number
      
      page.should have_content(tala_tank_kit.name)
    end

    it "updated stock count" do
      pending "TODO"

    end
  end

  #------------------------------------------------------------------------------
  
  def add_optional_part_to(kit)
    visit spree.admin_product_parts_path(kit)

    fill_in "searchtext", with: needle.name
    fill_in "part_count", with: 2
    check "part_optional"
    click_link "Select"

    expect(current_path).to eql(spree.admin_product_parts_path(kit))
    find_field('count').value.to_i.should eql(2)
    find("#part_optional").should be_checked
  end

  def add_required_part_to(kit, variant)
    visit spree.admin_product_variant_parts_path(kit, variant)

    fill_in "searchtext", with: wool.name
    fill_in "part_count", with: 3
    click_link "Select"

    expect(current_path).to eql(spree.admin_product_variant_parts_path(kit, variant))
    find_field('count').value.to_i.should eql(3)
  end

  def fill_in_address
    address = "order_bill_address_attributes"
    fill_in "#{address}_firstname", :with => "Ryan"
    fill_in "#{address}_lastname", :with => "Bigg"
    fill_in "#{address}_address1", :with => "143 Swan Street"
    fill_in "#{address}_city", :with => "Richmond"
    select "Alabama", :from => "#{address}_state_id"
    fill_in "#{address}_zipcode", :with => "12345"
    fill_in "#{address}_phone", :with => "(555) 555-5555"
  end

  def add_product_to_cart(product)
  end


end
