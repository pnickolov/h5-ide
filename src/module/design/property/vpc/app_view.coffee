#############################
#  View(UI logic) for design/property/vpc(app)
#############################

define [ '../base/view', './template/app' ], ( PropertyView, template ) ->

    VPCAppView = PropertyView.extend {

        render : () ->
            @$el.html template @model.attributes
            @model.attributes.name
    }

    new VPCAppView()
