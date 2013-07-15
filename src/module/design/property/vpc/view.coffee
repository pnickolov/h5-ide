#############################
#  View(UI logic) for design/property/vpc
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    VPCView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-vpc-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:vpc render'

    }

    view = new VPCView()

    return view