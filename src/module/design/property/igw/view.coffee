#############################
#  View(UI logic) for design/property/igw
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

   IGWView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-igw-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:igw render'

    }

    view = new IGWView()

    return view