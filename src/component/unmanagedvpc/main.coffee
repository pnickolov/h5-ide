####################################
#  pop-up for component/unmanagedvpc module
####################################

define [ 'jquery', 'event' ], ( $, ide_event ) ->

    #private
    loadModule = () ->

        #
        require [ 'unmanagedvpc_view', 'unmanagedvpc_model' ], ( View, Model ) ->

            # new view and model
            view  = new View()
            model = new Model()

            # set model
            view.model    = model

            model.on 'change:resource_list', () ->
                console.log 'change:resource_list', model.get 'resource_list'
                view.render()

            # UPDATE_IMPORT_ITEM
            ide_event.onLongListen ide_event.UPDATE_IMPORT_ITEM, ( idx ) ->
                console.log 'UPDATE_IMPORT_ITEM'
                model.getResource idx

            # invoke api
            model.getStatResourceService()

            # listen
            view.on 'CLOSE_POPUP', () ->
                unLoadModule view, model

            # render
            view.render()

    unLoadModule = ( view, model ) ->
        console.log 'unmanaged vpc unLoadModule'
        view.off()
        model.off()
        view.undelegateEvents()
        #
        view  = null
        model = null
        #
        ide_event.offListen ide_event.UPDATE_IMPORT_ITEM
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule