####################################
#  Controller for design/property/stack module
####################################

define [ 'jquery',
         'text!/module/design/property/stack/template.html',
         'text!/module/design/property/stack/acl_template.html',
         'event'
], ( $, template, acl_template, ide_event ) ->

    #
    current_view  = null
    current_model = null
    current_sub_main = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-stack-tmpl">' + template + '</script>'
    acl_template = '<script type="text/x-handlebars-template" id="property-stack-acl-tmpl">' + acl_template + '</script>'
    #load remote html template
    $( 'head' ).append template
    $( 'head' ).append acl_template

    #private
    loadModule = ( current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/stack/view',
                  './module/design/property/stack/model',
                  './module/design/property/sglist/main'
        ], ( view, model, sglist_main ) ->

            #
            if current_view then view.delegateEvents view.events

            current_sub_main = sglist_main

            #
            current_view  = view
            current_model = model

            ###
            ide_event.onLongListen ide_event.RETURN_SUBNET_PROPERTY_FROM_ACL, (mainModule) ->
                view.refreshACLList()
                mainModule.unLoadModule()
            ###

            #view
            view.model    = model
            #render
            renderPropertyPanel = () ->
                model.getStack()
                # model.getSecurityGroup()
                view.render()
                sglist_main.loadModule model, true

            renderPropertyPanel()

            view.on 'STACK_NAME_CHANGED', (name) ->
                console.log 'stack name changed and refresh'
                MC.canvas_data.name = name
                renderPropertyPanel()

            view.on 'DELETE_STACK_SG', (uid) ->
                model.deleteSecurityGroup uid

            view.on 'RESET_STACK_SG', (uid) ->
                model.resetSecurityGroup uid
                view.render view.model.attributes

                sglist_main.loadModule model


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
