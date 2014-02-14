####################################
#  pop-up for component/stateeditor module
####################################

define [ 'event', 'ace', 'ace_ext_language_tools',  'UI.modal', 'jquery_sort', 'jquery_markdown' ], ( ide_event ) ->

    #private
    loadModule = ( allCompData, uid ) ->

        #
        require [ 'stateeditor_view', 'stateeditor_model' ], ( View, Model ) ->

            # add test
            # MC.forge.other.addSEList canvas_data

            compData = allCompData[uid]
            resModel = Design.instance().component(uid)

            model = new Model({
                compData: compData,
                resModel: resModel,
                allCompData: allCompData
            })
            view  = new View({
                model: model
            })

            view.model = model

            ide_event.onLongListen ide_event.UPDATE_STATE_STATUS_DATA_TO_EDITOR, model.listenStateStatusUpdate, model

            view.on 'CLOSE_POPUP', () ->
                unLoadModule view, model

            model.on 'STATE_STATUS_UPDATE', (newStateUpdateResIdAry) ->
                view.onStateStatusUpdate(newStateUpdateResIdAry)

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