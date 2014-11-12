#############################
#  View(UI logic) for design/property/cgw(app)
#############################

define [ '../base/view', './template/app' ], ( PropertyView, template ) ->

    CGWAppView = PropertyView.extend {
        events:
            'change #property-res-desc'       : 'onChangeDescription'

        render : () ->
            @$el.html template _.extend isEditable: @model.isAppEdit, @model?.toJSON()
            @model.get 'id'

        onChangeDescription : (event) -> @model.setDesc $(event.currentTarget).val()
    }

    new CGWAppView()
