#############################
#  View(UI logic) for design/property/acl
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

   ACLView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-acl-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:acl render'

    }

    view = new ACLView()

    return view