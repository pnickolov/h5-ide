#############################
#  View(UI logic) for design/property/az
#############################

define [ '../base/view', 'text!./template/stack.html' ], ( PropertyView, template ) ->

    template = Handlebars.compile template

    AZView = PropertyView.extend {

        events   :
            'OPTION_CHANGE #az-quick-select' : "azSelect"

        render     : () ->
            console.log 'property:az render', this.model.attributes

            @$el.html template @model.attributes
            "Availability Zone"

        azSelect   : ( event, newAZName ) ->
            this.trigger "SELECT_AZ", $("#az-quick-select").attr("component"), newAZName
    }

    new AZView()
