#############################
#  View(UI logic) for design/property/elb(app)
#############################

define [ 'event', 'MC',
         'text!/module/design/property/elb/app_template.html',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC, template ) ->

    ElbAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile template

        render     : () ->
            console.log 'property:elb app render'
            $( '.property-details' ).html this.template this.model.attributes


    }
    
    view = new ElbAppView()

    return view