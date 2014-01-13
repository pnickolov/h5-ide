####################################
#  pop-up for component/statestatus module
####################################

define [ 'jquery', 'event' ], ( $, ide_event ) ->

    # Private
    loadModule = ( status ) ->

        require [ './component/statestatus/view', './component/statestatus/model' ], ( View, Model ) ->

            view  = new View()
            model = new Model()

            view.model    = model
            view.render()

    unLoadModule = ( view, model ) ->

        view.remove()
        model.destroy()
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    # Public
    loadModule   : loadModule
    unLoadModule : unLoadModule