#############################
#  View(UI logic) for design/property/elb(app)
#############################

define [ '../base/view',
         'text!./template/app.html'], ( PropertyView, template ) ->

    template = Handlebars.compile template

    ElbAppView = PropertyView.extend {

        render : () ->
            @$el.html template @model.attributes
            @model.attributes.name
    }

    new ElbAppView()
