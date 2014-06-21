#############################
#  View(UI logic) for design/property/eni(app)
#############################

define [ '../base/view', './template/app' ], ( PropertyView, template ) ->

    RtbAppView = PropertyView.extend {

        render : () ->
            @$el.html template @model.attributes
            @model.attributes.name
    }

    new RtbAppView()
