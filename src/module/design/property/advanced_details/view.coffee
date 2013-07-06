#############################
#  View(UI logic) for design/property/advanced_details
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    AdvancedDetailsView = Backbone.View.extend {

        el                  : $ '.advanced-details'
        #accordion_item_tmpl : Handlebars.compile $( '#accordion-item-tmpl' ).html()

    }

    view = new AdvancedDetailsView()

    return view