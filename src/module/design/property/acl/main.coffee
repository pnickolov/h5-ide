####################################
#  Controller for design/property/acl module
####################################

define [ 'jquery',
         'text!/module/design/property/acl/template.html',
         'text!/module/design/property/acl/app_template.html',
         'text!/module/design/property/acl/rule_item.html',
         'text!/component/aclrule/template.html',
         'event'
], ( $, template, app_template, rule_template, acl_popup_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template     = '<script type="text/x-handlebars-template" id="property-acl-tmpl">' + template + '</script>'
    app_template  = '<script type="text/x-handlebars-template" id="property-acl-app-tmpl">' + app_template + '</script>'
    rule_template     = '<script type="text/x-handlebars-template" id="property-acl-rule-tmpl">' + rule_template + '</script>'
    acl_popup_template  = '<script type="text/x-handlebars-template" id="property-acl-rule-popup-tmpl">' + acl_popup_template + '</script>'

    #load remote html template
    $( 'head' ).append( template ).append( app_template ).append( rule_template ).append( acl_popup_template )

    #private
    loadModule = ( uid_parent, expended_accordion_id, uid, tab_type ) ->

        #
        MC.data.current_sub_main = this

        that = this

        #set view_type
        if tab_type is 'OPEN_APP' then view_type = 'app_view' else view_type = 'view'

        #
        require [ './module/design/property/acl/' + view_type,
                  './module/design/property/acl/model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #model
            model.init uid

            #view
            view.model    = model

            view.on 'ADD_RULE_TO_ACL', (value) ->
                model.addRuleToACL uid, value

            model.on 'REFRESH_RULE_LIST', (value) ->
                view.refreshRuleList value

            view.on 'REMOVE_RULE_FROM_ACL', (ruleNum, ruleEngress) ->
                model.removeRuleFromACL uid, ruleNum, ruleEngress

            view.on 'ACL_NAME_CHANGED', (aclName) ->
                model.setACLName uid, aclName

            view.on ide_event.RETURN_SUBNET_PROPERTY_FROM_ACL, () ->
                ide_event.trigger ide_event.RETURN_SUBNET_PROPERTY_FROM_ACL, that

            #render
            view.render expended_accordion_id

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
