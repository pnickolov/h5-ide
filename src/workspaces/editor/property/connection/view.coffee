#############################
#  View(UI logic) for design/property/cgw
#############################

define [ '../base/view', './template/stack' ], ( PropertyView, template ) ->

    ConnectionView = PropertyView.extend {
        render : () ->
            @$el.html template @model.attributes
            @model.attributes.name
    }

    new ConnectionView()
