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
            acl_uid = $("#property-app-subnet-acl").attr("data-uid")
            subnet_uid = $("#subnet-property-panel").data('uid')
            console.log "Show ACL Sub Panel for Subnet", acl_uid, subnet_uid

            this.trigger 'OPEN_ACL', acl_uid, subnet_uid
    }

    view = new SubnetAppView()

    return view
