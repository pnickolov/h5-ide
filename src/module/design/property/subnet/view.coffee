#############################
#  View(UI logic) for design/property/subnet
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    SubnetView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-subnet-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:subnet render'

    }

    view = new SubnetView()

    return view