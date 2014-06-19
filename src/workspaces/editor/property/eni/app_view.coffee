#############################
#  View(UI logic) for design/property/eni(app)
#############################

define [ '../base/view', './template/app', './template/eni_list'], ( PropertyView, template, list_template ) ->

    EniAppView = PropertyView.extend {

        render : () ->
            @$el.html template @model.attributes

            if @model.isGroupMode
              $("#prop-appedit-eni-list").html list_template @model.attributes

            @model.attributes.name
    }

    new EniAppView()
