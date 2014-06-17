####################################
#  pop-up for component/amis module
####################################

define [ 'jquery', 'event', 'component/amis/view', 'component/amis/model' ], ( $, ide_event, View, Model ) ->

    #private
    loadModule = () ->

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
        console.log 'ami unLoadModule'
        view.off()
        model.off()
        view.undelegateEvents()
        #
        view  = null
        model = null
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>
        null

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
