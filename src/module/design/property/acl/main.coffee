####################################
#  Controller for design/property/acl module
####################################

define [ 'jquery',
         'text!/module/design/property/acl/template.html',
         'text!/module/design/property/acl/rule_item.html',
         'event'
], ( $, template, rule_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template     = '<script type="text/x-handlebars-template" id="property-acl-tmpl">' + template + '</script>'
    rule_template     = '<script type="text/x-handlebars-template" id="property-acl-rule-tmpl">' + rule_template + '</script>'

    #load remote html template
    $( 'head' ).append template
    $( 'head' ).append rule_template

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

            view.on 'ADD_RULE_TO_ACL', (value) ->
                view.model.addRuleToACL uid, value

            model.on 'REFRESH_RULE_LIST', (value) ->
                view.refreshRuleList uid, value

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