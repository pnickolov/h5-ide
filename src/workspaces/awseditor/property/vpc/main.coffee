####################################
#  Controller for design/property/vpc module
####################################

define [ '../base/main',
         './model',
         './view',
         './app_model',
         './app_view',
         'constant'
], ( PropertyModule, model, view, app_model, app_view, constant ) ->

    VPCModule = PropertyModule.extend {

        handleTypes : constant.RESTYPE.VPC

        initStack : () ->
            @model = model
            @model.isAppEdit = false
            @view  = view
            null

        initApp : () ->
            @model = app_model
            @view  = app_view
            null

        initAppEdit : () ->
            @model = model
            @model.isAppEdit = true
            @view  = view
            null
    }

    null
