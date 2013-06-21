require 'spec_helper'

describe Spree::Admin::VariantPartsController do
  stub_authorization!
  let(:ability_user) { stub_model(Spree::LegacyUser, :has_spree_role? => true) }

  before do
    @product = create(:product) 
    @variant = create(:variant, :product => @product)

    @product_can_be_part = create(:product, :can_be_part => true, :available_on => Time.now - 15.minutes) 
    @variant_part = create(:variant, :product => @product_can_be_part)

    @product.parts.push @variant_part
    @variant.parts.push @variant_part

    @new_product_can_be_part = create(:product, :can_be_part => true, :available_on => Time.now - 15.minutes) 
    @new_variant_part = create(:variant, :product => @new_product_can_be_part)

  end

  context "#index" do
    it "list all current parts of product" do
      spree_get :index, {:variant_id => @variant.id}
      response.should be_success 
      assigns[:parts].map(&:id).should == [@variant_part.id]
    end
  end

  context "available" do
    it "list all available parts" do
      can_not_be_part = create(:product, :can_be_part => false) 
      spree_get :available, {:q=>"%", :variant_id => @variant.id } 
      response.should be_success 
      assigns[:available_products].map(&:id).should == [@product_can_be_part.id, @new_product_can_be_part.id]
    end
  end

  context "create" do
    it "can add a new part for a product" do
      spree_post :create, { :format => 'js', :variant_id => @variant.id, :part_count => 2, :part_id => @new_variant_part.id } 
      response.should be_success 
      assigns[:part].id.should == @new_variant_part.id

      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts].map(&:id).should == [@variant_part.id, @new_variant_part.id]
      assigns[:parts].map { |p| @variant.count_of(p) }.should == [1,2]
    end
  end

  context "remove" do
    it "can decrement a part for a product" do
      @variant.add_part @new_variant_part, 2

      spree_post :remove, { :format => 'js', :variant_id => @variant.id, :id => @new_variant_part.id } 
      response.should be_success 
      assigns[:part].id.should == @new_variant_part.id

      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts].map(&:id).should == [@variant_part.id, @new_variant_part.id]
      assigns[:parts].map { |p| @variant.count_of(p) }.should == [1,1]
    end
  end

  context "set_count" do
    it "can set quantity of a part" do
      @variant.add_part @new_variant_part, 2

      spree_post :set_count, { :format => 'js', :variant_id => @variant.id, :id => @new_variant_part.id, :count => 99 } 
      response.should be_success 
      assigns[:part].id.should == @new_variant_part.id

      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts].map(&:id).should == [@variant_part.id, @new_variant_part.id]
      assigns[:parts].map { |p| @variant.count_of(p) }.should == [1,99]
    end
  end





end
