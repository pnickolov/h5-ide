#############################
#  View(UI logic) for design/property/elb
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    ELBView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-elb-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:elb render'

    }

    view = new ELBView()

    return view