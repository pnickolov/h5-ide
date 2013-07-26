#############################
#  View(UI logic) for design/property/elb(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    ElbAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template  : Handlebars.compile $( '#property-elb-app-tmpl' ).html()

        render     : () ->
            console.log 'property:elb app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes


    }
    
    view = new ElbAppView()

    return view
