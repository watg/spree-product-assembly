require 'spec_helper'

describe "Optional Parts" do
  let!(:needle) { create(:product,
                          product_type: :part,
                          price: 10,
                          kit_price: 7,
                          name: "Needles") }
  let!(:wool) { create(:product,
                          product_type: :part,
                          price: 15,
                          kit_price: 12,
                          name: "Wool") }
  let!(:tala_tank) { create(:product,
                          product_type: :kit,
                          price: 45,
                          name: "Tala Tank") }

  stub_authorization!
  
  before { visit spree.admin_product_parts_path(tala_tank) }
  
  it "should be possible on product parts", js: true do
    fill_in "searchtext", with: "nee"
    fill_in "part_count", with: 2
    check "part_optional"
    click_link "Select"

    expect(current_path).to eql(spree.admin_product_parts_path(tala_tank))
    find_field('count').value.to_i.should eql(2)
    find("#part_optional").should be_checked
  end

end
