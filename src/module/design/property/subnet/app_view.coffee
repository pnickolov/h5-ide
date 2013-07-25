#############################
#  View(UI logic) for design/property/vpc(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    SubnetAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template  : Handlebars.compile $( '#property-subnet-app-tmpl' ).html()

        render     : () ->
            console.log 'property:subnet app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes


    }

    view = new SubnetAppView()

    return view
