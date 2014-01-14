####################################
#  pop-up for component/statestatus module
####################################

define [ 'jquery', 'event' ], ( $, ide_event ) ->

    # Private
    loadModule = ( status ) ->

        require [ './component/statestatus/view', './component/statestatus/model' ], ( View, Model ) ->

            model = new Model()
            view  = new View model: model

            ide_event.onLongListen ide_event.UPDATE_STATE_STATUS_DATA, model.listenStateStatusUpdate

            view.render()

    unLoadModule = ( view, model ) ->

        view.remove()
        model.destroy()
        ide_event.offListen ide_event.UPDATE_STATE_STATUS_DATA

    # Public
    loadModule   : loadModule
    unLoadModule : unLoadModule