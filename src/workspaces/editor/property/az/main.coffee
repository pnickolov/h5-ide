####################################
#  Controller for design/property/az module
####################################

define [ '../base/main', './model', './view', 'constant' ], ( PropertyModule, model, view, constant ) ->

    AZModule = PropertyModule.extend {

        handleTypes : "Stack:" + constant.RESTYPE.AZ

        initStack : ()->
            # Quick hack.
            # In AppEdit, AZ's property will be opened.
            # Throw an error to do nothing.
            if Design.instance().modeIsAppEdit()
                throw new Error("Cannot open az property panel in AppEdit mode.")

            @model = model
            @view  = view
            null
    }

    null

