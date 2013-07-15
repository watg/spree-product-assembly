//= require admin/spree_backend
$(document).ready(function() { 
  var variant_parts_url = $(".assembly_parts_variant_autocomplete").data('url') || ''; 
  $(".assembly_parts_variant_autocomplete").select2({
    placeholder: Spree.translations.type_to_search,
    minimumInputLength: 3,

    initSelection: function(element, callback) {
      var variant_id=$(element).val();
      if (variant_id !== "") {
        $.ajax({
          type: "GET",
          async: false,
          url: Spree.url(Spree.routes.variants_search),
          data: {
            q: {
              "id_eq": variant_id
            }
          } 
        }).done(function(data) { 
          callback(data.variants[0]); 
        });
      }
    },
    ajax: {
      url: Spree.url(variant_parts_url),
      type: "POST",
      datatype: 'json',
      data: function(term, page) {
        return { q: term }
      },
      results: function (data, page) {
        return { results: data }
      }
    },
    formatResult: function (variant) {
      var options = new Array();
      $.each(variant.option_values,function(index, value){ 
        options.push( value.presentation ); 
      });
      return [variant.name, ' (', options.join(', '), ')'].join("");
    },
    formatSelection: function (variant) {
        var options = new Array();
        $.each(variant.option_values,function(index, value){ 
          options.push( value.presentation ); 
        });
      $(this.element).parent().children('.options_placeholder').html(variant.option_values)
      return [variant.name, ' (', options.join(', '), ')'].join("");
    }
  })
});

/// need to create a parts api controller 

