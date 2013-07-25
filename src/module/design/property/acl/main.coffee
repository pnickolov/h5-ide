####################################
#  Controller for design/property/acl module
####################################

define [ 'jquery',
         'event'
], ( $, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #private
    loadModule = ( uid_parent, expended_accordion_id, uid ) ->

        #
        MC.data.current_sub_main = this

        #
        require [ './module/design/property/acl/view', './module/design/property/acl/model' ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #model
            model.init uid

            #view
            view.model    = model

            view.off()

            view.on 'ADD_RULE_TO_ACL', (value) ->
                view.model.addRuleToACL uid, value

            model.on 'REFRESH_RULE_LIST', (value) ->
                view.refreshRuleList value

            view.on 'REMOVE_RULE_FROM_ACL', (ruleNum, ruleEngress) ->
                view.model.removeRuleFromACL uid, ruleNum, ruleEngress

            view.on 'ACL_NAME_CHANGED', (aclName) ->
                view.model.setACLName uid, aclName

            #render
            view.render expended_accordion_id, model.attributes

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule