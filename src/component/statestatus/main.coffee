####################################
#  pop-up for component/statestatus module
####################################

define [ 'jquery', 'event', './component/statestatus/view', './component/statestatus/model' ], ( $, ide_event, View, Model ) ->

    # Private
    loadModule = ( status ) ->

        model = new Model()
        view  = new View model: model

        view.on 'CLOSE_POPUP', () ->
            @unLoadModule view, model
        , @

        ide_event.onLongListen ide_event.UPDATE_STATE_STATUS_DATA, model.listenStateStatusUpdate, model
        ide_event.onLongListen 'STATE_EDITOR_DATA_UPDATE', model.listenStateEditorUpdate, model

        view.render()
        # test
        window.ide_event = ide_event

    unLoadModule = ( view, model ) ->

        view.remove()
        model.destroy()
        ide_event.offListen ide_event.UPDATE_STATE_STATUS_DATA
        ide_event.offListen 'STATE_EDITOR_DATA_UPDATE'

    # Public
    loadModule   : loadModule
    unLoadModule : unLoadModule