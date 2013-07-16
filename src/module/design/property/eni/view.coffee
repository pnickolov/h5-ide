#############################
#  View(UI logic) for design/property/eni
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

   ENIView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-eni-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:eni render'

    }

    view = new ENIView()

    return view