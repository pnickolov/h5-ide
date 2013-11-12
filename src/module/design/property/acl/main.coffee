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
            @model.on 'REFRESH_RULE_LIST', (value) ->
                me.view.refreshRuleList value
            null

        initStack : () ->
            @model = model
            @model.isApp = false
            @view  = view
            null

        afterLoadStack : () ->
            @view.refreshRuleList()
            null

        initApp : () ->
            @model = model
            @model.isApp = true
            @view = app_view
            null

        initAppEdit : () ->
            @model = model
            @model.isApp = true
            @view = app_view
            null
    }
    null
