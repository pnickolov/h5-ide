####################################
#  Controller for design/property/stack module
####################################

define [ 'jquery',
         'text!/module/design/property/stack/template.html',
         'text!/module/design/property/stack/app_template.html',
         'text!/module/design/property/stack/acl_template.html',
         'text!/module/design/property/stack/sub_template.html',
         'event'
], ( $, stack_template, app_template, acl_template, sub_template, ide_event ) ->

    #
    current_view     = null
    current_model    = null
    current_sub_main = null
    #
    onceCache        = []

    #add handlebars script
    stack_template = '<script type="text/x-handlebars-template" id="property-stack-tmpl">' + stack_template + '</script>'
    app_template   = '<script type="text/x-handlebars-template" id="property-app-tmpl">' + app_template + '</script>'
    acl_template   = '<script type="text/x-handlebars-template" id="property-stack-acl-tmpl">' + acl_template + '</script>'
    sub_template   = '<script type="text/x-handlebars-template" id="property-stack-sns-tmpl">' + sub_template + '</script>'

    #load remote html template
    $( 'head' ).append stack_template
    $( 'head' ).append app_template
    $( 'head' ).append acl_template
    $( 'head' ).append sub_template

    #private
    loadModule = ( current_main, tab_type ) ->
        console.log 'stack main, tab_type = ' + tab_type

        #
        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP' then view_type = 'app_view' else view_type = 'view'

        #
        require [ './module/design/property/stack/' + view_type,
                  './module/design/property/stack/model',
                  './module/design/property/sglist/main'
        ], ( view, model, sglist_main ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            ide_event.onLongListen ide_event.PROPERTY_HIDE_SUBPANEL, ( id ) ->
                if id is "ACL"
                    view.refreshACLList()

            #view
            view.model    = model

            model.getCost()

            if view_type == 'app_view'

                model.getAppSubscription()

            else
                model.getSubscription()

            if tab_type is 'OPEN_APP'
                title = "APP - "
            else
                title = "Stack - "

            #render
            renderPropertyPanel = () ->
                model.getProperty()
                #model.getSecurityGroup()

                view.render()
                ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, title + model.attributes.property_detail.name

                current_sub_main = sglist_main

                sglist_main.loadModule model, true

            renderPropertyPanel()

            ide_event.onListen ide_event.RESOURCE_QUICKSTART_READY, () ->
                console.log 'onListen RESOURCE_QUICKSTART_READY'
                model.getCost()
                renderPropertyPanel()

            view.on 'STACK_NAME_CHANGED', (name) ->
                console.log 'stack name changed and refresh'
                MC.canvas_data.name = name
                renderPropertyPanel()

                ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, title + name
                ide_event.trigger ide_event.UPDATE_TABBAR, MC.canvas_data.id, name

            view.on 'DELETE_STACK_SG', (uid) ->
                model.deleteSecurityGroup uid

            view.on 'RESET_STACK_SG', (uid) ->
                model.resetSecurityGroup uid
                view.render()
                current_sub_main = sglist_main
                sglist_main.loadModule model

            #
            resourceQuickstartReturn = () ->
                console.log 'resource quickstart return'
                model.getCost()
            if !onceCache.resourceQuickstartReturn
                onceCache.resourceQuickstartReturn = true
                ide_event.onLongListen ide_event.RESOURCE_QUICKSTART_READY, resourceQuickstartReturn

            #
            stackUpdateStackList = ( flag ) ->
                console.log 'stack:UPDATE_STACK_LIST'
                renderPropertyPanel() if flag is 'NEW_STACK'
            if !onceCache.stackUpdateStackList
                onceCache.stackUpdateStackList = true
                ide_event.onLongListen ide_event.UPDATE_STACK_LIST, stackUpdateStackList

            model.on 'UPDATE_COST_LIST', () ->
                console.log 'rerender property'
                renderPropertyPanel()

            view.on 'SAVE_SUBSCRIPTION', ( data ) ->
                console.log 'SAVE_SUBSCRIPTION'
                model.addSubscription data

            model.on 'UPDATE_SNS_LIST', ( sns_list, has_asg ) ->
                console.log 'UPDATE_SNS_LIST'
                view.updateSNSList sns_list, has_asg

            view.on 'DELETE_SUBSCRIPTION', ( uid ) ->
                console.log 'DELETE_SUBSCRIPTION'
                model.deleteSNS uid

            ###
            #refresh cost after add/remove resource
            ide_event.onLongListen ide_event.UPDATE_COST_ESTIMATE, () ->
                model.getCost()
            ###
            #
            null

    unLoadModule = () ->
        console.log 'stack unLoadModule'
        #
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #
        if current_sub_main then current_sub_main.unLoadModule()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
