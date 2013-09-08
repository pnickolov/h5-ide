####################################
#  Controller for design/property/acl module
####################################

define [ 'jquery',
         'text!./template.html',
         'text!./app_template.html',
         'text!./rule_item.html',
         'text!acl_template',
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
    loadModule = ( uid, tab_type ) ->

        #
        MC.data.current_sub_main = this

        #that = this

        #set view_type
        if tab_type is 'OPEN_APP' then view_type = 'app_view' else view_type = 'view'

        #
        require [ './module/design/property/acl/' + view_type,
                  './module/design/property/acl/model'
        ], ( view, model ) ->

            # added by song
            model.clear({silent: true})
            
            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #model
            if tab_type is 'OPEN_APP'
                model.appInit uid
            else
                model.init uid

            #view
            view.model    = model

            #render
            $dom = view.render()
            ide_event.trigger ide_event.PROPERTY_OPEN_SUBPANEL, {
                title : model.attributes.component.name
                dom   : $dom
                id    : "ACL"
            }

            view.refreshRuleList(MC.canvas_data.component[uid])

            #temp hack
            view._events = []

            view.on 'ADD_RULE_TO_ACL', (value) ->
                model.addRuleToACL uid, value

            model.on 'REFRESH_RULE_LIST', (value) ->
                view.refreshRuleList value

            view.on 'REMOVE_RULE_FROM_ACL', (ruleNum, ruleEngress) ->
                model.removeRuleFromACL uid, ruleNum, ruleEngress

            view.on 'ACL_NAME_CHANGED', (aclName) ->
                model.setACLName uid, aclName

    unLoadModule = () ->
        # current_view.off()
        # current_model.off()
        # current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
