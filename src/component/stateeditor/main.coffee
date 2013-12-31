####################################
#  pop-up for component/stateeditor module
####################################

define [ 'event', 'UI.modal', 'jquery_caret', 'jquery_atwho' ], ( ide_event ) ->

    #private
    loadModule = ( canvas_data, uid ) ->

        #
        require [ 'stateeditor_view', 'stateeditor_model' ], ( View, Model ) ->

            # add test
            MC.forge.other.addSEList canvas_data

            compData = canvas_data.component[uid]

            model = new Model({
                compData: compData
            })
            view  = new View({
                model: model
            })

            view.model = model

            view.on 'CLOSE_POPUP', () ->
                unLoadModule view, model

            view.render()

    unLoadModule = ( view, model ) ->
        console.log 'state editor unLoadModule'
        view.off()
        model.off()
        view.undelegateEvents()
        modal.close()

        #
        view  = null
        model = null
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule