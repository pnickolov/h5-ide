#############################
#  View(UI logic) for design/property/cgw
#############################

define [ '../base/view', 'text!./template/stack.html' ], ( PropertyView, template ) ->

    template = Handlebars.compile template

    StaticSubView = PropertyView.extend {
        render : () ->
            @$el.html template @model.attributes
            if @model.attributes.ami then "Ami" else "Snapshot"
    }

    new StaticSubView()
