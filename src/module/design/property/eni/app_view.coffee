#############################
#  View(UI logic) for design/property/eni(app)
#############################

define [ '../base/view', 'text!./template/app.html', 'text!./template/eni_list.html'], ( PropertyView, template, list_template ) ->

    template      = Handlebars.compile template
    list_template = Handlebars.compile list_template

    EniAppView = PropertyView.extend {

        render : () ->
            @$el.html template @model.attributes

            if @model.isGroupMode
              $("#prop-appedit-eni-list").html list_template @model.attributes

            @model.attributes.name
    }

    new EniAppView()
