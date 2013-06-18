Deface::Override.new(:virtual_path => "spree/admin/variants/index",
                     :name => "add_parts_action_to_variant",
                     :replace => "[data-hook='variants_row']",
                     :partial => "spree/admin/variants/variants_row",
                     :disabled => false)
