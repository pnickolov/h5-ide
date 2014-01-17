#############################
#  View(UI logic) for design/property/cgw(app)
#############################

define [ '../base/view', 'text!./template/app.html' ], ( PropertyView, template ) ->

    template = Handlebars.compile template

    CGWAppView = PropertyView.extend {

        render : () ->
            @$el.html template @model.toJSON()
            @model.get 'name'
    }

    new CGWAppView()
