#############################
#  View(UI logic) for design/property/cgw
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

   CGWView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-cgw-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:cgw render'

    }

    view = new CGWView()

    return view