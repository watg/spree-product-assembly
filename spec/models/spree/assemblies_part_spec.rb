require 'spec_helper'

module Spree
  describe AssembliesPart do
    # we fix the id's to try and surface any bugs that may be in the polymorphism
#    let(:product) { create(:product, :id => 123) }
#    let(:variant) { create(:variant) }
#    let(:variant2) { create(:variant, :id => 123) }
#
#    before do
#      product.parts.push variant
#      variant2.parts.push variant
#    end
#
#    context "get" do
#      it "brings part by product and variant id" do
#        subject.class.get(product.class, product.id, variant.id).part.should == variant
#      end
#
#      it "brings part by variant and variant id" do
#         subject.class.get(variant2.class, variant2.id, variant.id).part.should == variant
#      end
#    end
#
#    context "save" do
#      it "should update the count" do
#        ap = subject.class.get(product.class, product.id, variant.id)
#        ap.count = 22
#        ap.save
#        ap.count.should == 22
#        ap.assembly.should == product 
#      end
#
#      it "should update the count" do
#        ap = subject.class.get(variant2.class, variant2.id, variant.id)
#        ap.count = 22
#        ap.save
#        ap.count.should == 22
#        ap.assembly.should == variant2
#      end
#    end
#
#    context "destroy" do
#      it "should delete the object for product" do
#        ap = subject.class.get(product.class, product.id, variant.id)
#        ap.destroy
#        ap = subject.class.get(product.class, product.id, variant.id)
#        ap.should be_nil
#      end
#
#      it "should delete the object for variant" do
#        ap = subject.class.get(variant2.class, variant2.id, variant.id)
#        ap.destroy
#        ap = subject.class.get(variant2.class, variant2.id, variant.id)
#        ap.should be_nil
#      end
#    end
#

  end
end
