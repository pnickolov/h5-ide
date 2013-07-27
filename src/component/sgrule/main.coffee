####################################
#  pop-up for component/sgrule module
####################################

define [ 'jquery', 'event' ], ( $, ide_event ) ->

    #private
    loadModule = () ->

        #
        require [ './component/sgrule/view', './component/sgrule/model' ], ( View, Model ) ->

            #
            view  = new View()
            model = new Model()

            #view
            view.model    = model
            #
            view.on 'CLOSE_POPUP', () ->
                unLoadModule view, model

            #render
            view.render()

    unLoadModule = ( view, model ) ->
        console.log 'sgrule unLoadModule'
        view.off()
        model.off()
        view.undelegateEvents()
        #
        view  = null
        model = null
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
