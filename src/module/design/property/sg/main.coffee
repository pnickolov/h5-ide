####################################
#  Controller for design/property/sg module
####################################

define [ '../base/main', './model', './view' ], ( PropertyModule, model, view ) ->

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
