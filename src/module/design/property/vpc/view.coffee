#############################
#  View(UI logic) for design/property/vpc
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars',
        'UI.fixedaccordion' ], ( ide_event ) ->

    VPCView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-vpc-tmpl' ).html()

        #events   :

        render   : ( attributes ) ->
            $( '.property-details' ).html this.template attributes
            fixedaccordion.resize()

    }

    view = new VPCView()

    return view
