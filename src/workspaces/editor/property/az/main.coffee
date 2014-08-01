####################################
#  Controller for design/property/az module
####################################

define [ '../base/main', './model', './view', 'constant' ], ( PropertyModule, model, view, constant ) ->

    AZModule = PropertyModule.extend {

        handleTypes : constant.RESTYPE.AZ

        initStack : ()->
            if Design.instance().modeIsAppEdit() then return false

            @model = model
            @view  = view
            null

        initApp : ()-> false
    }

    null

