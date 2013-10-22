####################################
#  Controller for design/property/subnet module
####################################

define [ '../base/main',
         './model',
         './view',
         './app_model',
         './app_view',
         'constant'
], ( PropertyModule, model, view, app_model, app_view, constant ) ->

    SubnetModule = PropertyModule.extend {

        handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet

        onUnloadSubPanel : ( id )->
            if id is "ACL"
                @view.refreshACLList()

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

            @view.on 'OPEN_ACL', ( acl_uid ) ->
                PropertyModule.loadSubPanel "ACL", acl_uid
                null
            null

        initStack : () ->
            @view  = view
            @model = model
            null

        setupApp : () ->
            @view.on 'OPEN_ACL', ( acl_uid ) ->
                PropertyModule.loadSubPanel "ACL", acl_uid
                null

        initApp : () ->
            @view  = app_view
            @model = app_model
            null
    }
    null

