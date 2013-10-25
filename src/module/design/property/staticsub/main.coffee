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
            null

        initApp : () ->
            @model = model
            @view  = view
            null

        initAppEdit : () ->
            @model = model
            @view  = view
            null
    }
    null
