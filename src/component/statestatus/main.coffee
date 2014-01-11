####################################
#  pop-up for component/statestatus module
####################################

define ['jquery', 'event'], ($, ide_event) ->

    #private
    loadModule = (status) ->

        require [ './component/statestatus/view', './component/statestatus/model' ], (View, Model) ->

            view  = new View()
            model = new Model()

            view.model    = model
            view.render()

    unLoadModule = (view, model) ->

        view.off()
        model.off()
        view.undelegateEvents()

        view  = null
        model = null
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule