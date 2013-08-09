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
    current_view  = null
    current_model = null
    current_sub_main = null

    #add handlebars script
    stack_template = '<script type="text/x-handlebars-template" id="property-stack-tmpl">' + stack_template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-app-tmpl">' + app_template + '</script>'
    acl_template = '<script type="text/x-handlebars-template" id="property-stack-acl-tmpl">' + acl_template + '</script>'

    sub_template = '<script type="text/x-handlebars-template" id="property-stack-sns-tmpl">' + sub_template + '</script>'

    #load remote html template
    $( 'head' ).append stack_template
    $( 'head' ).append app_template
    $( 'head' ).append acl_template
    $( 'head' ).append sub_template

    #private
    loadModule = ( current_main, tab_type ) ->
        console.log 'elb main, tab_type = ' + tab_type

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

            current_sub_main = sglist_main

            #
            current_view  = view
            current_model = model

            ide_event.onLongListen ide_event.PROPERTY_HIDE_SUBPANEL, ( id ) ->
                if id is "ACL"
                    view.refreshACLList()

            #view
            view.model    = model

            #re calc cost when load module
            model.getCost()

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

                sglist_main.loadModule model, true

            renderPropertyPanel()

            view.on 'STACK_NAME_CHANGED', (name) ->
                console.log 'stack name changed and refresh'
                MC.canvas_data.name = name
                renderPropertyPanel()

                ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, title + name

            view.on 'DELETE_STACK_SG', (uid) ->
                model.deleteSecurityGroup uid

            view.on 'RESET_STACK_SG', (uid) ->
                model.resetSecurityGroup uid

                view.render()

                sglist_main.loadModule model

            ide_event.onLongListen ide_event.RESOURCE_QUICKSTART_READY, () ->
                console.log 'resource quickstart return'

                model.getCost()

            ide_event.onLongListen ide_event.UPDATE_STACK_LIST, (flag) ->
                console.log 'UPDATE_STACK_LIST'

                if flag is 'NEW_STACK'
                    renderPropertyPanel()

            model.on 'UPDATE_COST_LIST', () ->
                console.log 'rerender property'

                renderPropertyPanel()

            #refresh cost after add/remove resource
            ide_event.onLongListen ide_event.UPDATE_COST_ESTIMATE, () ->

                model.getCost()

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()

        current_sub_main.unLoadModule()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
