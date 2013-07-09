require 'spec_helper'

module Spree
  describe OrderInventoryAssembly do
    let(:order) { create(:order_with_line_items) }
    let(:line_item) { order.line_items.first }
    let(:bundle) { line_item.product }
    let(:parts) { (1..3).map { create(:variant) } }

    before do
      bundle.parts << [parts]
      bundle.set_part_count(parts.first, 3)

      line_item.update_attributes!(quantity: 3)
      order.reload.create_proposed_shipments
      order.finalize!
    end

    subject { OrderInventoryAssembly.new(line_item.reload) }

    context "inventory units count" do
      it "calculates the proper value for the bundle" do
        expected_units_count = line_item.quantity * bundle.assemblies_parts.sum(&:count)
        expect(subject.inventory_units.count).to eql(expected_units_count)
      end
    end

    context "verify line item units" do
      let!(:original_units_count) { line_item.quantity * bundle.assemblies_parts.sum(&:count) }

      context "quantity increases" do
        before { subject.line_item.quantity += 1 }

        it "inserts new inventory units for every bundle part" do
          expected_units_count = original_units_count + bundle.assemblies_parts.sum(&:count)
          subject.verify
          expect(OrderInventoryAssembly.new(line_item).inventory_units.count).to eql(expected_units_count)
        end
      end

      context "quantity decreases" do
        before { subject.line_item.quantity -= 1 }

        it "remove inventory units for every bundle part" do
          expected_units_count = original_units_count - bundle.assemblies_parts.sum(&:count)
          subject.verify
          expect(OrderInventoryAssembly.new(line_item).inventory_units.count).to eql(expected_units_count)
        end
      end
    end
  end
end
