####################################
#  Controller for design/property/vgw module
####################################

define [ '../base/main', './model', './view', 'constant' ], ( PropertyModule, model, view, constant )->

    StaticModule = PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.VGW, constant.RESTYPE.IGW ]

        initStack : ()->
            @model = model
            @view  = view
            @model.isApp = false
            null

        initApp : ()->
            @model = model
            @view  = view
            @model.isApp = true
            null

        initAppEdit : ()->
            @model = model
            @view  = view
            @model.isApp = true
            null
    }

    null
