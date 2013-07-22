#############################
#  View(UI logic) for design/property/rtb
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars', 'UI.multiinputbox' ], ( ide_event ) ->

    RTBView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-rtb-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:rtb render'
            $( '.property-details' ).html this.template this.model.attributes

    }

    view = new RTBView()

    return view