#############################
#  View(UI logic) for design/property/elb(app)
#############################

define [ 'event', 'MC', 'UI.zeroclipboard', 'UI.notification'
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    ElbAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template  : Handlebars.compile $( '#property-elb-app-tmpl' ).html()

        render     : () ->
            console.log 'property:elb app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes

            # Init Clipbard
            new ZeroClipboard( $("#property-app-elb-dnss .icon-copy") )
            null
    }

    view = new ElbAppView()

    return view
