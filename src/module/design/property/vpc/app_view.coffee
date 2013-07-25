#############################
#  View(UI logic) for design/property/vpc(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    VPCAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template  : Handlebars.compile $( '#property-vpc-app-tmpl' ).html()

        render     : () ->
            console.log 'property:eni app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes


    }

    view = new VPCAppView()

    return view
