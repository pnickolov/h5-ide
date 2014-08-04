####################################
#  Controller for design/property/az module
####################################

define [ '../base/main', './model', './view', 'constant' ], ( PropertyModule, model, view, constant ) ->

    AZModule = PropertyModule.extend {

        handleTypes : constant.RESTYPE.AZ

        initStack : ()->
            @model = model
            @view  = view
            @view.isAppEdit = false
            return

        initApp : ()-> false

        initAppEdit : ()->
            @model = model
            @view  = view
            @view.isAppEdit = true
            return

    }

    null

