#############################
#  View(UI logic) for design/property/az
#############################

define [ '../base/view', './template/stack' ], ( PropertyView, template ) ->

    AZView = PropertyView.extend {

        events   :
            'OPTION_CHANGE #az-quick-select' : "azSelect"

        render   : () ->
            @$el.html template @model.attributes
            "Availability Zone"

        azSelect : ( event, newAZName ) ->
            this.trigger "SELECT_AZ", newAZName
    }

    new AZView()
