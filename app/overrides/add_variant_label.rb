Deface::Override.new(:virtual_path => "spree/admin/variants/_form",
                     :name => "variant_description",
                     :insert_bottom => "[data-hook='admin_variant_form_additional_fields']",
                     :partial => "spree/admin/variants/label")
