####################################
#  pop-up for component/stateeditor module
####################################

define [ 'event', 'ace', 'ace_ext_language_tools',  'UI.modal', 'jquery_sort', 'markdown' ], ( ide_event ) ->

    #private
    loadModule = ( allCompData, uid ) ->

        that = this

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

            ide_event.offListen ide_event.STATE_EDITOR_SAVE_DATA
            ide_event.onLongListen ide_event.STATE_EDITOR_SAVE_DATA, () ->
                if view.editorShow
                    view.onStateSaveClick()
                that.unLoadModule()

            $( '#property-panel' ).addClass 'state'
            $( '#property-panel .sub-stateeditor' ).html view.render().el

    unLoadModule = ( view, model ) ->
        console.log 'state editor unLoadModule'

        try

            view.off()
            model.off()
            view.undelegateEvents()
            modal.close()

            #
            view  = null
            model = null
            ide_event.offListen ide_event.UPDATE_STATE_STATUS_DATA_TO_EDITOR
            #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

        catch err

            null

        return

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
