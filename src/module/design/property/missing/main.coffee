####################################
#  Controller for design/property/cgw module
####################################

define [ '../base/main', '../base/model', '../base/view' ], ( PropertyModule, PropertyModel, PropertyView ) ->

    MissingView = PropertyView.extend {
        render : () ->
            @$el.html MC.template.missingPropertyPanel()
            "Resource Unavailable"
    }

    view  = new MissingView()
    model = new PropertyModel()

    MissingModule = PropertyModule.extend {

        handleTypes : "missing_resource"

        initApp : () ->
            @model = model
            @view  = view
            null
    }
    null
