require 'spec_helper'

describe "Parts", js: true do
  stub_authorization!

  let(:tshirt) { create(:product, :name => "T-Shit", :product_type => 'kit') }
  let(:mug) { create(:product, :name => "Mug", :product_type => 'part') }

  before do
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
