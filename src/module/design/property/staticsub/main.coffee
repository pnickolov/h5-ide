####################################
#  Controller for design/property/cgw module
####################################

define [ '../base/main',
         './model',
         './view'
], ( PropertyModule, model, view ) ->

    StaticSubModule = PropertyModule.extend {

        subPanelID : "STATIC"

        initStack : ()->
            @model = model
            @view  = view
            @model.isApp = false
            null

        initApp : () ->
            @model = model
            @view  = view
            @model.isApp = true
            null

        initAppEdit : () ->
            @model = model
            @view  = view
            @model.isApp = true
            null
    }
    null
