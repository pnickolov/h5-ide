#############################
#  View(UI logic) for design/property/stack(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    InstanceAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template  : Handlebars.compile $( '#property-stack-app-tmpl' ).html()

        render     : () ->
            console.log 'property:instance app render'
            $( '.property-details' ).html this.template this.model.attributes

    }

    view = new InstanceAppView()

    return view