#############################
#  View(UI logic) for design/property/volume(app)
#############################

define [ '../base/view', './template/app' ], ( PropertyView, template ) ->

    VolumeView = PropertyView.extend {

        render : () ->
            @$el.html template @model.attributes
            @model.attributes.name
    }

    new VolumeView()
