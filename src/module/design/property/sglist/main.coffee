####################################
#  Controller for design/property/sglist module
####################################

define [ './model',
         './view',
         'event'
], ( model, view, ide_event ) ->

    view.on 'ASSIGN_SG_TOCOMP', (sgUID, sgChecked) ->
        model.assignSGToComp sgUID, sgChecked
        ide_event.trigger ide_event.REDRAW_SG_LINE

    view.on 'DELETE_SG_FROM_COMP', (sgUID) ->
        model.deleteSGFromComp sgUID
        ide_event.trigger ide_event.REDRAW_SG_LINE

    view.on 'OPEN_SG', (sgUID) ->
        ide_event.trigger ide_event.OPEN_SG, sgUID

    view.model = model

    refresh = () ->
        view.render()
        null

    loadModule = ( parent_model ) ->
        model.set 'parent_model', parent_model
        model.set 'app_view', MC.canvas.getState() is 'app'

        view.render()
        null

    onUnloadSubPanel = ( id ) ->
        if id is "SG"
            view.render()


    #public
    loadModule       : loadModule
    refresh          : refresh
    onUnloadSubPanel : onUnloadSubPanel
