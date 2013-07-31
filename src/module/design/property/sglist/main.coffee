####################################
#  Controller for design/property/sglist module
####################################

define [ 'jquery',
         'text!/module/design/property/sglist/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-sg-list-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( parent_model ) ->

        current_main = this

        require [ './module/design/property/sglist/view', './module/design/property/sglist/model' ], ( view, model ) ->

            if current_view then view.delegateEvents view.events

            #variable set
            current_view  = view
            current_model = model
            view.parent_model    = parent_model
            view.model = model
            model.set 'parent_model', parent_model

            ide_event.onLongListen ide_event.RETURN_PANEL_PROPERTY_FROM_SG, () ->
                view.render()

            #init model
            model.getSGInfoList()

            model.getRuleInfoList()

            view.on 'ASSIGN_SG_TOCOMP', (sgUID, sgChecked) ->
                model.assignSGToComp sgUID, sgChecked

            view.on 'DELETE_SG_FROM_COMP', (sgUID) ->
                model.deleteSGFromComp sgUID

            view.on 'OPEN_SG', (sgUID) ->
                ide_event.trigger ide_event.OPEN_SG, sgUID, current_main

            #render
            view.render()

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        ide_event.offListen ide_event.RETURN_PANEL_PROPERTY_FROM_SG
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
    sg_main      : null
