#############################
#  View(UI logic) for design/property/cgw(app)
#############################

define [ '../base/view', './template/app' ], ( PropertyView, template ) ->

    CGWAppView = PropertyView.extend {

        render : () ->
            @$el.html template @model?.toJSON()
            @model.get 'id'
    }

    new CGWAppView()
