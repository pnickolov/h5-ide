####################################
#  pop-up for component/sgrule module
####################################

define [ 'event', './view', './model' ], ( ide_event, View, Model ) ->

    #private
    loadModule = ( line_id, delete_module ) ->

        view  = new View()
        model = new Model({
            uid : line_id
            deleteMode : delete_module
        })

        view.model = model
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
