####################################
#  Controller for design/property/launchconfig module
####################################

define [ '../base/main',
         './model',
         './view',
         'constant',
         './app_model',
         './app_view'
], ( PropertyModule, model, view, constant, app_model, app_view ) ->

    AsgModule = PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.ASG, "ExpandedAsg" ]

        initStack : ()->
            @model = model
            @view  = view
            null

        initApp : ()->
            @model = app_model
            @model.isAppEdit = false
            @view = app_view
            null

        initAppEdit : ()->
            @model = app_model
            @model.isAppEdit = true
            @view = app_view
            null
    }
    null

