#############################
#  View(UI logic) for design/property/vpc(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    SubnetAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template  : Handlebars.compile $( '#property-subnet-app-tmpl' ).html()
        events    :
            "click #property-app-subnet-acl" : 'showACLDetail'

        render     : () ->
            console.log 'property:subnet app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes

        showACLDetail : () ->
            this.trigger 'OPEN_ACL', $("#property-app-subnet-acl").attr("data-uid")
    }

    view = new SubnetAppView()

    return view
