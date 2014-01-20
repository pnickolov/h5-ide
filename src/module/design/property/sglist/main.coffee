####################################
#  Controller for design/property/sglist module
####################################

define [ '../base/main',
         './model',
         './view',
         'event'
], ( PropertyModel, model, view, ide_event ) ->

    view.on 'OPEN_SG', (sgUID) ->
        PropertyModel.loadSubPanel "SG", sgUID
        null

    view.model = model

    refresh = () ->
        view.render()
        null

    loadModule = ( parent_model ) ->
        model.parent_model = parent_model
        view.render()
        null

    onUnloadSubPanel = ( id ) ->
        if id is "SG"
            view.render()


    #public
    loadModule       : loadModule
    refresh          : refresh
    onUnloadSubPanel : onUnloadSubPanel
