require 'spec_helper'

describe Spree::Admin::ProductPartsController do
  stub_authorization!

  let(:ability_user) { stub_model(Spree::LegacyUser, :has_spree_role? => true) }


  let(:product) { create(:product) }
  let(:variant) { create(:variant, :product => product) }
  let(:variant2) { create(:variant) }

  before do
    product.parts.push variant
    variant2.parts.push variant
  end

  context "#index" do
    it "list all current parts of product" do
      spree_get :index, {:product_id => product}
      response.should be_success 
      assigns[:parts].map(&:id).should == [variant.id]
    end
  end

  context "available" do
    it "list all available parts" do
      can_be_part = create(:product, :can_be_part => true, :available_on => Time.now - 15.minutes) 
      can_not_be_part = create(:product, :can_be_part => false) 

      spree_get :available, {:q=>"%", :product_id => product } 
      response.should be_success 
      assigns[:available_products].map(&:id).should == [can_be_part.id]
    end
  end

  context "create" do
    it "can add a new part for a product" do
      can_be_part = create(:product, :can_be_part => true, :available_on => Time.now - 15.minutes) 
      variant_part = create(:variant, :product => can_be_part)
      spree_post :create, { :format => 'js', :product_id => product.permalink, :part_count => 2, :part_id => variant_part.id } 
      response.should be_success 
      assigns[:part].id.should == variant_part.id

      spree_get :index, {:product_id => product}
      assigns[:parts].map(&:id).should == [variant.id, variant_part.id]
      assigns[:parts].map { |p| product.count_of(p) }.should == [1,2]
    end
  end

  context "remove" do
    it "can decrement a part for a product" do
      can_be_part = create(:product, :can_be_part => true, :available_on => Time.now - 15.minutes) 
      variant_part = create(:variant, :product => can_be_part)
      product.add_part variant_part, 2

      spree_post :remove, { :format => 'js', :product_id => product.permalink, :id => variant_part.id } 
      response.should be_success 
      assigns[:part].id.should == variant_part.id

      spree_get :index, {:product_id => product}
      assigns[:parts].map(&:id).should == [variant.id, variant_part.id]
      assigns[:parts].map { |p| product.count_of(p) }.should == [1,1]
    end
  end

  context "set_count" do
    it "can set quantity of a part" do
      can_be_part = create(:product, :can_be_part => true, :available_on => Time.now - 15.minutes) 
      variant_part = create(:variant, :product => can_be_part)
      product.add_part variant_part, 2

      spree_post :set_count, { :format => 'js', :product_id => product.permalink, :id => variant_part.id, :count => 99 } 
      response.should be_success 
      assigns[:part].id.should == variant_part.id

      spree_get :index, {:product_id => product}
      assigns[:parts].map(&:id).should == [variant.id, variant_part.id]
      assigns[:parts].map { |p| product.count_of(p) }.should == [1,99]
    end
  end





end
