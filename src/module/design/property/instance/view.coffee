#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    InstanceView = Backbone.View.extend {

        el                  : $ '.property-details'
        #accordion_item_tmpl : Handlebars.compile $( '#accordion-item-tmpl' ).html()

        render     : ( template ) ->
            console.log 'property:instance render'
            $( '.property-details' ).html template

    }

    view = new InstanceView()

    return view