#############################
#  View(UI logic) for design/property/elb(app)
#############################

define [ 'event', 'MC', 'UI.zeroclipboard', 'UI.notification'
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC, zeroclipboard ) ->

    ElbAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template  : Handlebars.compile $( '#property-elb-app-tmpl' ).html()

        render     : () ->
            console.log 'property:elb app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes

            # Init Clipbard
            zeroclipboard.copy $("#property-app-elb-dnss .icon-copy")
            null
    }

    view = new ElbAppView()

    return view
