####################################
#  pop-up for component/statestatus module
####################################

define [ 'jquery', 'event', './component/statestatus/view', './component/statestatus/model' ], ( $, ide_event, View, Model ) ->

    model = null
    view = null

    # Private
    loadModule = ->

        model = new Model()
        view  = new View model: model

        view.on 'CLOSE_POPUP', @unLoadModule, @

        ide_event.onLongListen ide_event.UPDATE_STATE_STATUS_DATA, model.listenStateStatusUpdate, model
        ide_event.onLongListen ide_event.STATE_EDITOR_DATA_UPDATE, model.listenStateEditorUpdate, model

        view.render()

    unLoadModule = ->

        view.remove()
        model.destroy()
        ide_event.offListen ide_event.UPDATE_STATE_STATUS_DATA, model.listenStateStatusUpdate
        ide_event.offListen ide_event.STATE_EDITOR_DATA_UPDATE


    # Public
    loadModule   : loadModule
    unLoadModule : unLoadModule

