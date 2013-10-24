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
            @view.on 'ADD_RULE_TO_ACL', (value) ->
                me.model.addRuleToACL value

            @model.on 'REFRESH_RULE_LIST', (value) ->
                me.view.refreshRuleList value

            @view.on 'REMOVE_RULE_FROM_ACL', (ruleNum, ruleEngress) ->
                me.model.removeRuleFromACL ruleNum, ruleEngress

            @view.on 'ACL_NAME_CHANGED', (aclName) ->
                me.model.setACLName aclName
            null

        initStack : () ->
            @model = model
            @model.isApp = false
            @view  = view
            null

        afterLoadStack : () ->
            @view.refreshRuleList()
            null

        setupApp : () ->
            null

        initApp : () ->
            @model = model
            @model.isApp = true
            @view = app_view
            null
    }
    null
