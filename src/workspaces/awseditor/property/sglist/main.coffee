####################################
#  Controller for design/property/sglist module
####################################

define [ '../base/main',
         './model',
         './view'
], ( PropertyModel, model, view ) ->

    view.on 'OPEN_SG', (sgUID) ->
        PropertyModel.loadSubPanel "SG", sgUID
        null

    view.model = model

    refresh = () ->
        view.render()
        null

    loadModule = ( parent_model ) ->
        model.parent_model = parent_model
        model.resId = parent_model.get('uid') or parent_model.id
        view.render()
        null

    onUnloadSubPanel = ( id ) ->
        if id is "SG"
            view.render()


    #public
    loadModule       : loadModule
    refresh          : refresh
    onUnloadSubPanel : onUnloadSubPanel
