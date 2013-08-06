#############################
#  View(UI logic) for design/property/acl(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    ACLAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template  : Handlebars.compile $( '#property-acl-app-tmpl' ).html()

        render     : () ->
            console.log 'property:acl app render'
            this.template this.model.attributes

    }

    view = new ACLAppView()

    return view
