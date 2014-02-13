####################################
#  Controller for design/property/acl module
####################################

define [ "../base/main",
         './model',
         './view',
         'event'
], ( PropertyModule, model, view ) ->

    model.on 'REFRESH_RULE_LIST', () ->
        view.refreshRuleList()

    AclModule = PropertyModule.extend {

        subPanelID  : "ACL"

        initStack : () ->
            @model = model
            @model.isApp = false
            @view  = view
            null

        initApp : () ->
            @model = model
            @model.isApp = true
            @view = view
            null

        initAppEdit : () ->
            @model = model
            @model.isApp = false
            @view = view
            null
    }
    null
