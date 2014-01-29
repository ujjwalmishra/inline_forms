# -*- encoding : utf-8 -*-
InlineForms::SPECIAL_COLUMN_TYPES[:dropdown_with_other]=:belongs_to

# dropdown
def dropdown_with_other_show(object, attribute)
  foreign_key = object.class.reflect_on_association(attribute.to_sym).options[:foreign_key] || attribute.to_s.foreign_key.to_sym
  id = object[foreign_key]
  if id == 0
    attribute_value = object[attribute.to_s + '_other']
    attribute_value = "<i class='fi-plus'></i>".html_safe if attribute_value.nil? || attribute_value.empty?
  else
    attribute_value = object.send(attribute)._presentation rescue  "<i class='fi-plus'></i>".html_safe
  end
  link_to_inline_edit object, attribute, attribute_value
end

def dropdown_with_other_edit(object, attribute)
  foreign_key = object.class.reflect_on_association(attribute.to_sym).options[:foreign_key] || attribute.to_s.foreign_key.to_sym
  #  object.send('build_' + attribute.to_s) unless object.send(attribute)
  o = attribute.capitalize.constantize
  if cancan_enabled?
    values = o.accessible_by(current_ability).order(o.order_by_clause)
  else
    values = o.order(o.order_by_clause)
  end
  values.each do |v|
    v.name = v._presentation
  end
  values.sort_by! &:name
  collection = values.map {|v|[v.name, v.id]}
  collection << [object[attribute.to_s + '_other'], 0] unless object[attribute.to_s + '_other'].nil? || object[attribute.to_s + '_other'].empty?
  out = '<div class="ui-widget">'
  out << select('_' + object.class.to_s.underscore, foreign_key.to_sym, collection, {selected: object[foreign_key.to_sym], prompt: 'maake een keuze'}, {id: '_' + object.class.to_s.underscore + '_' + object.id.to_s + '_'  + foreign_key.to_s})
  #  collection_select( ('_' + object.class.to_s.underscore).to_sym, attribute.to_s.foreign_key.to_sym, values, 'id', 'name', :selected => object.send(attribute).id)
  out << '</div>
  <script>
    (function( $ ) {
    $.widget( "custom.combobox", {
      _create: function() {
        this.wrapper = $( "<span>" )
          .addClass( "custom-combobox" )
          .insertAfter( this.element );
 
        this.element.hide();
        this._createAutocomplete();
        this._createShowAllButton();
      },
 
      _createAutocomplete: function() {
        var selected = this.element.children( ":selected" ),
          value = selected.val() ? selected.text() : "";
 
        this.input = $( "<input name=\''
        
    out << '_' + object.class.to_s.underscore + '[' + attribute.to_s + '_other]' 
        
        out << '\'>" )
          .appendTo( this.wrapper )
          .val( value )
          .attr( "title", "" )
          .addClass( "custom-combobox-input ui-widget ui-widget-content ui-state-default ui-corner-left" )
          .autocomplete({
            delay: 0,
            minLength: 0,
            source: $.proxy( this, "_source" )
          })
          .tooltip({
            tooltipClass: "ui-state-highlight"
          });
 
        this._on( this.input, {
          autocompleteselect: function( event, ui ) {
            ui.item.option.selected = true;
            this._trigger( "select", event, {
              item: ui.item.option
            });
          }
        });
      },
 
      _createShowAllButton: function() {
        var input = this.input,
          wasOpen = false;
 
        $( "<a>" )
          .attr( "tabIndex", -1 )
          .attr( "title", "Show All Items" )
          .tooltip()
          .appendTo( this.wrapper )
          .button({
            icons: {
              primary: "ui-icon-triangle-1-s"
            },
            text: false
          })
          .removeClass( "ui-corner-all" )
          .addClass( "custom-combobox-toggle ui-corner-right" )
          .mousedown(function() {
            wasOpen = input.autocomplete( "widget" ).is( ":visible" );
          })
          .click(function() {
            input.focus();
 
            // Close if already visible
            if ( wasOpen ) {
              return;
            }
 
            // Pass empty string as value to search for, displaying all results
            input.autocomplete( "search", "" );
          });
      },
 
      _source: function( request, response ) {
        var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
        response( this.element.children( "option" ).map(function() {
          var text = $( this ).text();
          if ( this.value && ( !request.term || matcher.test(text) ) )
            return {
              label: text,
              value: text,
              option: this
            };
        }) );
      },
    });
  })( jQuery );
 
  $(function() {
    $( "'
    out << '#_' + object.class.to_s.underscore + '_' + object.id.to_s + '_' + attribute.to_s.foreign_key.to_s 
    out << '" ).combobox();
  });
  </script>'
  out.html_safe
  
  
end

def dropdown_with_other_update(object, attribute)
  foreign_key = object.class.reflect_on_association(attribute.to_sym).options[:foreign_key] || attribute.to_s.foreign_key.to_sym
  # if there is an attribute attr, then there must be an attribute attr_other
  other = params[('_' + object.class.to_s.underscore).to_sym][(attribute.to_s + "_other").to_sym]
  # see if it matches anything
  match = attribute.capitalize.constantize.where(name: other).first # problem if there are dupes!
  match.nil? ? object[foreign_key] = 0 : object[foreign_key] = match.id # problem if there is a record with id: 0 !
  match.nil? ? object[attribute.to_s + '_other'] = other : object[attribute.to_s + '_other'] = nil  
end

