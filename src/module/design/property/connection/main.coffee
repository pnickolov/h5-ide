####################################
#  Controller for design/property/cgw module
####################################

define [ '../base/main',
         './model',
         './view'
], ( PropertyModule, model, view ) ->

    ConnectionModule = PropertyModule.extend {

        handleTypes : [ "EniAttachment", "ElbSubnetAsso" ]

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
