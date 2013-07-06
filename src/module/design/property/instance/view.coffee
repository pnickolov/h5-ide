#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    InstanceView = Backbone.View.extend {

        el                  : $ '.instance-details'
        #accordion_item_tmpl : Handlebars.compile $( '#accordion-item-tmpl' ).html()

    }

    view = new InstanceView()

    return view