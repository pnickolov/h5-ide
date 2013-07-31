#############################
#  View(UI logic) for design/property/elb(app)
#############################

define [ 'event', 'MC', 'zeroclipboard', 'UI.notification'
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC, ZeroClipboard ) ->

    ElbAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template  : Handlebars.compile $( '#property-elb-app-tmpl' ).html()

        render     : () ->
            console.log 'property:elb app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes

            # Init Clipbard
            clip = new ZeroClipboard( $("#property-app-elb-dnss .icon-copy"), { moviePath: "vender/zeroclipboard/ZeroClipboard.swf" })

            null
    }

    view = new ElbAppView()

    return view
