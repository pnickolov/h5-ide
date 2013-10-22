#############################
#  View(UI logic) for design/property/vpc(app)
#############################

define [ '../base/view', 'text!./template/app.html' ], ( PropertyView, template ) ->

    template = Handlebars.compile template

    VPCAppView = PropertyView.extend {

        render : () ->
            @$el.html template @model.attributes
            @model.attributes.name
    }

    new VPCAppView()
