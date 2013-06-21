require 'spec_helper'

describe Spree::Variant do
  before(:each) do
    #@product = FactoryGirl.create(:product, :name => "Foo Bar")
    #@variant = FactoryGirl.create(:variant, :product => @product )
    #@master_variant = Spree::Variant.find_by_product_id(@product.id, :conditions => ["is_master = ?", true])
  end
    
  describe "Spree::Variant Assembly" do
    before(:each) do
      @product1 = create(:product, :can_be_part => true, :id => 99)
      @product2 = create(:product, :can_be_part => true, :id => 100)
      @product3 = create(:product, :can_be_part => true, :id => 101)
      @product4 = create(:product, :can_be_part => true, :id => 102)

      @part1 = create(:variant, :product => @product1, :id => 99 )  # part 1
      @part2 = create(:variant, :product => @product2, :id => 100 ) # part 2

      @variant1 = create(:variant, :product => @product3, :id => 101 ) # part 3
      @variant2 = create(:variant, :product => @product3, :id => 102 ) # part 3
      @variant3 = create(:variant, :product => @product3, :id => 103 ) # part 3

      @variant1.add_part @part1, 1
      @variant1.add_part @part2, 4
      @variant2.add_part @part1, 2
    end

    it "does not confuse product and variant in the polmorphic assemblies_parts table" do
      # We create a product1 and variant with the same id, so that when they get added
      # to to the assemblies_parts table we can detect if assemblies_type is not being
      # useed
      product1 = create(:product, :id => 201)

      product2 = create(:product)
      variant = create(:variant, :product => product2, :id => 201)

      product3 = create(:product, :can_be_part => true)
      part1 = create(:variant, :product => product3 )

      product4 = create(:product, :can_be_part => true)
      part2 = create(:variant, :product => product4 )

      product1.add_part part1, 1
      variant.add_part part2, 1

      product1.parts.map(&:id).should == [part1.id]
      variant.parts.map(&:id).should == [part2.id]
    end
    
    it "is an assembly" do
      @variant1.should be_assembly
    end

    it "is not an assembly" do
      @variant3.should_not be_assembly
    end
 
    it "is a part of an assebly" do
      @part1.should be_part
    end

    it "is not a part of an assebly" do
      part = create(:variant, :product => @product2 ) # part 2
      part.should_not be_part
    end
    
    it 'can add to a part count' do
      @variant1.add_part(@part2, 4)
      @variant1.count_of(@part2).should == 8 
    end

 
    it 'can remove a part count' do
      @variant1.remove_part(@part2)
      @variant1.count_of(@part2).should == 3 
    end

    it 'changing part qty changes count on_hand' do
      @variant1.set_part_count(@part2, 2)
      @variant1.count_of(@part2).should == 2
    end

    it 'provide us with a list of kit_parts and their counts' do
      @variant1.kit_parts.map(&:id).should == [ @part1.id, @part2.id ]
      @variant1.kit_parts.map(&:count_part).should == [ 1,4 ]
    end

    it "can detect which assemblies a part belongs to" do
      @part1.assemblies_for(@variant1,@variant2).map(&:id).should == [ @variant1.id, @variant2.id ] 
      @part2.assemblies_for(@variant1,@variant2).map(&:id).should == [ @variant1.id ] 
    end
    
  end
end
