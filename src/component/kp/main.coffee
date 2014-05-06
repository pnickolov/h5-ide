define [ './component/kp/view', './component/kp/model' ], ( View, Model ) ->


    # Private
    loadModule = ->

        model = new Model()
        view  = new View model: model

        view.render()

    unLoadModule = ->

        view.remove()
        model.destroy()
        ide_event.offListen ide_event.UPDATE_STATE_STATUS_DATA, model.listenStateStatusUpdate
        ide_event.offListen ide_event.STATE_EDITOR_DATA_UPDATE
        ide_event.offListen ide_event.UPDATE_APP_STATE, model.listenUpdateAppState


    # Public
    loadModule   : loadModule
    unLoadModule : unLoadModule
