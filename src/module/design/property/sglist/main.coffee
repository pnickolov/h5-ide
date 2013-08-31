####################################
#  Controller for design/property/sglist module
####################################

define [ 'jquery',
         'text!./template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-sg-list-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    refresh = () ->
        current_view.render()

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

            ide_event.onLongListen ide_event.PROPERTY_HIDE_SUBPANEL, (id) ->
                if id is "SG"
                    view.render()

            is_app_view = false
            currentState = MC.canvas.getState()
            if currentState is 'app'
                is_app_view = true

            #init model
            model.set 'app_view', is_app_view
            model.getSGInfoList()
            model.getRuleInfoList()

            #render
            view.render()

            # temp hack
            view._events = []

            view.on 'ASSIGN_SG_TOCOMP', (sgUID, sgChecked) ->
                model.assignSGToComp sgUID, sgChecked
                ide_event.trigger ide_event.REDRAW_SG_LINE

            view.on 'DELETE_SG_FROM_COMP', (sgUID) ->
                model.deleteSGFromComp sgUID
                ide_event.trigger ide_event.REDRAW_SG_LINE

            view.on 'OPEN_SG', (sgUID) ->
                ide_event.trigger ide_event.OPEN_SG, sgUID

            null

    unLoadModule = () ->
        if !current_view then return
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
    refresh      : refresh
    sg_main      : null
