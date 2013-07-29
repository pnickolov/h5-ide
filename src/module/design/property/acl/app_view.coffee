#############################
#  View(UI logic) for design/property/acl(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    InstanceAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template  : Handlebars.compile $( '#acl-secondary-panel' ).html()

        render     : () ->
            console.log 'property:acl app render'
            $( '.property-details' ).html this.template this.model.attributes

    }

    view = new ACLAppView()

    return view