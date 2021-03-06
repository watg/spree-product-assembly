require 'spec_helper'

describe Spree::Admin::VariantPartsController do
  stub_authorization!
  let(:ability_user) { stub_model(Spree::LegacyUser, :has_spree_role? => true) }

  before do
    @product = create(:product, :product_type => 'kit') 
    @variant = create(:variant, :product => @product)

    @product_can_be_part = create(:product, :product_type => 'product', :can_be_part => true, :available_on => Time.now - 15.minutes) 
    @variant_part = create(:variant, :product => @product_can_be_part)

    @product.parts.push @variant_part
    @variant.parts.push @variant_part

    @new_product_can_be_part = create(:product, :product_type => 'product', :can_be_part => true, :available_on => Time.now - 15.minutes) 
    @new_variant_part = create(:variant, :product => @new_product_can_be_part)

  end

  context "core actions" do

    context "#index" do
      it "list all current parts of product" do
        spree_get :index, {:variant_id => @variant.id}
        response.should be_success 
        assigns[:parts_for_display].map(&:id).should == [@variant_part.id]
      end
    end

    context "available" do
      it "list all available parts" do
        can_not_be_part = create(:product, :product_type => 'ready_to_wear') 
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
        assigns[:parts_for_display].map(&:id).should == [@variant_part.id, @new_variant_part.id]
        assigns[:parts_for_display].map { |p| @variant.count_of(p) }.should == [1,2]
      end
    end

    context "set_count" do
      it "can set quantity of a part" do
        @variant.add_part @new_variant_part, 2

        spree_post :set_count, { :format => 'js', :variant_id => @variant.id, :id => @new_variant_part.id, :part_count => 99 } 
        response.should be_success 
        assigns[:part].id.should == @new_variant_part.id

        spree_get :index, {:variant_id => @variant.id}
        assigns[:parts_for_display].map(&:id).should == [@variant_part.id, @new_variant_part.id]
        assigns[:parts_for_display].map { |p| @variant.count_of(p) }.should == [1,99]
      end
    end
  end

  context "add a part to the kit" do

    it "should allow you to do this with the optional flag disabled" do
        spree_post :create, { :format => 'js', :variant_id => @variant.id, :part_count => 2, :part_id => @new_variant_part.id, :part_optional => "false" } 
        spree_get :index, {:variant_id => @variant.id}
        assigns[:parts_for_display].map { |p| p.count_part }.should == [1,2]
        assigns[:parts_for_display].map { |p| p.optional_part }.should == [false,false]
    end

    it "should allow you to do this with the optional flag enabled" do
        spree_post :create, { :format => 'js', :variant_id => @variant.id, :part_count => 2, :part_id => @new_variant_part.id, :part_optional => "true" } 
        spree_get :index, {:variant_id => @variant.id}
        assigns[:parts_for_display].map { |p| p.count_part }.should == [1,2]
        assigns[:parts_for_display].map { |p| p.optional_part }.should == [false,true]
    end

    it "should update an identical part optional flag" do
      spree_post :create, { :format => 'js', :variant_id => @variant.id, :part_count => 9, :part_id => @variant_part.id, :part_optional => "false" } 
      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts_for_display].map { |p| p.count_part }.should == [10]
      assigns[:parts_for_display].map { |p| p.optional_part }.should == [false]
    end

    it "should update an identical part count" do
      spree_post :create, { :format => 'js', :variant_id => @variant.id, :part_count => 9, :part_id => @variant_part.id, :part_optional => "true" } 
      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts_for_display].map { |p| p.count_part }.should == [10]
      assigns[:parts_for_display].map { |p| p.optional_part }.should == [true]
    end
  end

  context "update a part" do

    it "should set a new count" do
      spree_post :set_count, { :format => 'js', :variant_id => @variant.id, :id => @variant_part.id, :part_count => 99 } 
      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts_for_display].map { |p| p.count_part }.should == [99]
    end

    it "should be able to set the optional checkbox" do
      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts_for_display].map { |p| p.optional_part }.should == [false]
      spree_post :set_count, { :format => 'js', :variant_id => @variant.id, :id => @variant_part.id, :part_optional => "true", :part_count => 99 } 
      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts_for_display].map { |p| p.optional_part }.should == [true]
    end

    it "should remove the part if count is set to zero" do
      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts_for_display].map { |p| p.count_part }.should == [1]
      spree_post :set_count, { :format => 'js', :variant_id => @variant.id, :id => @variant_part.id, :part_optional => "true", :part_count => 0 } 
      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts_for_display].should == []
    end

  end

  context "availability of parts" do

    it "should set a new count" do
      spree_post :set_count, { :format => 'js', :variant_id => @variant.id, :id => @variant_part.id, :part_count => 99 } 
      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts_for_display].map { |p| p.count_part }.should == [99]
    end

    it "should be able to set the optional checkbox" do
      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts_for_display].map { |p| p.optional_part }.should == [false]
      spree_post :set_count, { :format => 'js', :variant_id => @variant.id, :id => @variant_part.id, :part_optional => "true", :part_count => 99 } 
      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts_for_display].map { |p| p.optional_part }.should == [true]
    end

    it "should remove the part if count is set to zero" do
      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts_for_display].map { |p| p.count_part }.should == [1]
      spree_post :set_count, { :format => 'js', :variant_id => @variant.id, :id => @variant_part.id, :part_optional => "true", :part_count => 0 } 
      spree_get :index, {:variant_id => @variant.id}
      assigns[:parts_for_display].should == []
    end

  end



end
