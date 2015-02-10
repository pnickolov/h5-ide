#############################
#  View(UI logic) for design/property/elb(app)
#############################

define [ '../base/view', './template/app'], ( PropertyView, template ) ->

    ElbAppView = PropertyView.extend {

        render : () ->
            @$el.html template @model.attributes
            @model.attributes.name
    }

    new ElbAppView()
