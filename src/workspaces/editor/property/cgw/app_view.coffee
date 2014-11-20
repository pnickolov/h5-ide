#############################
#  View(UI logic) for design/property/cgw(app)
#############################

define [ '../base/view', './template/app' ], ( PropertyView, template ) ->

    CGWAppView = PropertyView.extend {
        events:
            'change #property-res-desc'       : 'onChangeDescription'
            "change #property-cgw-name"       : 'onChangeName'

        render : () ->
            @$el.html template _.extend isEditable: @model.isAppEdit, @model?.toJSON()
            @model.get 'id'

        onChangeName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if MC.aws.aws.checkResName( @model.get('uid'), target, "Customer Gateway" )
                @model.setName name
                @setTitle name

        onChangeDescription : (event) -> @model.setDesc $(event.currentTarget).val()
    }

    new CGWAppView()
