####################################
#  Controller for design/property/sg module
####################################

define [ '../base/main', './model', './view' ], ( PropertyModule, model, view ) ->

    # Because the model and view is shared between different property modes
    # Wire up the view and model here.
    view.on 'SET_SG_NAME', ( value ) ->
        model.setSGName value
        null

    view.on 'REMOVE_SG_RULE', ( rule )->
        model.removeSGRule  rule
        null

    view.on 'SET_SG_RULE', ( rule ) ->
        model.setSGRule rule
        null

    view.on 'SET_SG_DESC', ( value ) ->
        model.setSGDescription value
        null



    SgModule = PropertyModule.extend {

        subPanelID : "SG"

        initStack : () ->
            @model = model
            @model.isReadOnly = false
            @model.isAppEdit  = false
            @view  = view
            null

        initApp : ()->
            @model = model
            @model.isReadOnly = true
            @model.isAppEdit  = false
            @view  = view
            null

        initAppEdit : ()->
            @model = model
            @model.isReadOnly = false
            @model.isAppEdit  = true
            @view = view
            null
    }
    null
