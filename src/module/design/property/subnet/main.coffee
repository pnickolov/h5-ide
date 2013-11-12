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

    app_view.on 'OPEN_ACL', ( acl_uid ) ->
        PropertyModule.loadSubPanel "ACL", acl_uid

    view.on 'OPEN_ACL', ( acl_uid ) ->
        PropertyModule.loadSubPanel "ACL", acl_uid
        null

    SubnetModule = PropertyModule.extend {

        handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet

        onUnloadSubPanel : ( id )->
            if id is "ACL" and @view.refreshACLList
                @view.refreshACLList()

        initStack : () ->
            @view  = view
            @model = model
            null

        initApp : () ->
            @view  = app_view
            @model = app_model
            null

        initAppEdit : () ->
            @view  = app_view
            @model = app_model
            null
    }
    null

