####################################
#  pop-up for component/stateeditor module
####################################

define [ 'event', './view', './model', './lib/ace', 'UI.modal', 'jquerysort' ], ( ide_event, View, Model ) ->

    #private
    loadModule = ( allCompData, uid, resId, force ) ->

        compData = allCompData[uid]
        resModel = Design.instance().component(uid)

        if compData
            model = new Model({
                compData: compData,
                resModel: resModel,
                resId: resId,
                allCompData: allCompData
            })
        else
            model = new Backbone.Model()

        view  = new View({
            model: model
        })

        view.model = model

        ide_event.offListen ide_event.UPDATE_STATE_STATUS_DATA_TO_EDITOR
        ide_event.onLongListen ide_event.UPDATE_STATE_STATUS_DATA_TO_EDITOR, (newStateUpdateResIdAry) ->
            view.onStateStatusUpdate(newStateUpdateResIdAry)

        ide_event.offListen ide_event.STATE_EDITOR_SAVE_DATA
        ide_event.onLongListen ide_event.STATE_EDITOR_SAVE_DATA, (event) ->
            view.onMouseDownSaveFromOther(event)
        if not force
            $( '#OEPanelRight' ).addClass 'state'
        $( '#OEPanelRight .sub-stateeditor' ).html view.render().el

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

        return

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
