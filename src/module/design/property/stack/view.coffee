#############################
#  View(UI logic) for design/property/stack
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    StackView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-stack-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:stack render'

    }

    view = new StackView()

    return view