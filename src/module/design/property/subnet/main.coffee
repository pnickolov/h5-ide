####################################
#  Controller for design/property/subnet module
####################################

define [ '../base/main',
         './model',
         './view',
         './app_model',
         './app_view',
         'constant',
         'event'
], ( PropertyModule, model, view, app_model, app_view, constant, ide_event ) ->

    ideEvents = {}
    ideEvents[ ide_event.PROPERTY_HIDE_SUBPANEL ] = ( id ) ->
        if id is "ACL"
            view.refreshACLList()
        null

    SubnetModule = PropertyModule.extend {

        ideEvents   : ideEvents
        handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet

        setupStack : () ->
            me = this

            @view.on "CHANGE_NAME", ( change ) ->
                @model.setName change
                null

            @view.on "CHANGE_CIDR", ( change ) ->
                @model.setCIDR change
                null

            @view.on "CHANGE_ACL", ( change ) ->
                @model.setACL change
                null

            @view.on "SET_NEW_ACL", ( acl_uid ) ->
                @model.setACL acl_uid
                null
            null

        initStack : () ->
            @view  = view
            @model = model
            null

        setupApp : () ->
            @view.on 'OPEN_ACL', ( acl_uid ) ->
                ide_event.trigger ide_event.OPEN_ACL, acl_uid
                null

        initApp : () ->
            @view  = app_view
            @model = app_model
            null
    }
    null

