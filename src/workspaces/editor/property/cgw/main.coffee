####################################
#  Controller for design/property/cgw module
####################################

define [ '../base/main',
         './model',
         './view',
         './app_model',
         './app_view',
         'constant'
], ( PropertyModule, model, view, app_model, app_view, constant ) ->

    CGWModule = PropertyModule.extend {

        handleTypes : constant.RESTYPE.CGW

        initStack : ()->
            @model = model
            @view  = view
            null

        initApp : () ->
            @model = app_model
            @view  = app_view
            null

        initAppEdit : () ->
            @model = app_model
            @view  = app_view
            null
    }
    null
