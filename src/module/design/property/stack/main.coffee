####################################
#  Controller for design/property/stack module
####################################

define [ 'jquery',
         'text!/module/design/property/stack/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-stack-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/stack/view', './module/design/property/stack/model' ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            view.model    = model
            #render
            renderPropertyPanel = () ->
                view.model.getStack()
                view.render view.model.attributes

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


    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule