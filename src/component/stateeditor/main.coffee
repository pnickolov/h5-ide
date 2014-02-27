####################################
#  pop-up for component/stateeditor module
####################################

define [ 'event', 'ace', 'ace_ext_language_tools',  'UI.modal', 'jquery_sort', 'markdown' ], ( ide_event ) ->

    #private
    loadModule = ( allCompData, uid ) ->

        #
        require [ 'stateeditor_view', 'stateeditor_model' ], ( View, Model ) ->

            # add test
            # MC.forge.other.addSEList canvas_data

            compData = allCompData[uid]
            resModel = Design.instance().component(uid)

            if compData
                model = new Model({
                    compData: compData,
                    resModel: resModel,
                    allCompData: allCompData
                })
                model.on 'STATE_STATUS_UPDATE', (newStateUpdateResIdAry) ->
                    view.onStateStatusUpdate(newStateUpdateResIdAry)
            else
                model = new Backbone.Model()

            view  = new View({
                model: model
            })

            view.model = model

            ide_event.onLongListen ide_event.UPDATE_STATE_STATUS_DATA_TO_EDITOR, model.listenStateStatusUpdate, model


            $( '#property-panel' ).addClass 'state'
            $( '#property-panel' ).html view.render().el

    unLoadModule = ( view, model ) ->
        console.log 'state editor unLoadModule'
        view.off()
        model.off()
        view.undelegateEvents()
        modal.close()

        #
        view  = null
        model = null
        ide_event.offListen ide_event.UPDATE_STATE_STATUS_DATA_TO_EDITOR
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>
        return

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
