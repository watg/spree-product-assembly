require 'spec_helper'

describe "Parts", js: true do
  stub_authorization!

  let(:tshirt) { create(:product, :name => "T-Shit") }
  let(:mug) { create(:product, :name => "Mug") }

  before do
    visit spree.admin_product_path(mug)
    check "product_can_be_part"
    click_on "Update"
  end

  it "add and remove parts" do
    visit spree.admin_product_path(tshirt)
    click_on "Parts"
    fill_in "searchtext", with: "Mug"

    within("#search_hits") { click_on "Select" }
    page.should have_content(mug.sku)

    within("#item_parts") { click_on "Remove" }
  end
end
