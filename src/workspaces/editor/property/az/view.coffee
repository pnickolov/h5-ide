#############################
#  View(UI logic) for design/property/az
#############################

define [ '../base/view', './template/stack' ], ( PropertyView, template ) ->

    AZView = PropertyView.extend {

        events   :
            'OPTION_CHANGE #az-quick-select' : "azSelect"

        render   : () ->
            if @isAppEdit
              data = { appEdit : true }
            else
              data = @model.attributes

            @$el.html template data
            "Availability Zone"

        azSelect : ( event, newAZName ) -> @model.setName(newAZName); return
    }

    new AZView()
