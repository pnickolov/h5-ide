####################################
#  Controller for design/property/acl module
####################################

define [ "../base/main",
         './model',
         './view',
         './app_view',
         'event'
], ( PropertyModule, model, view, app_view ) ->


    AclModule = PropertyModule.extend {

        subPanelID  : "ACL"

        setupStack : () ->
            me = this
            @model.on 'REFRESH_RULE_LIST', () ->
                me.view.refreshRuleList()
            null

        initStack : () ->
            @model = model
            @model.isApp = false
            @model.isAppEdit = false
            @view  = view
            null

        afterLoadStack : () ->
            @view.refreshRuleList()
            null

        initApp : () ->
            @model = model
            @model.isApp = true
            @model.isAppEdit = false
            @view = app_view
            null

        initAppEdit : () ->
            @model = model
            @model.isApp = false
            @model.isAppEdit = true
            @view = app_view
            null
    }
    null
