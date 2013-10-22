#############################
#  View(UI logic) for design/property/elb(app)
#############################

define [ '../base/view',
         'text!./template/app.html',
         'UI.zeroclipboard' ], ( PropertyView, template, zeroclipboard ) ->

    template = Handlebars.compile template

    ElbAppView = PropertyView.extend {

        render : () ->
            $el.html template @model.attributes
            zeroclipboard.copy $("#property-app-elb-dnss .icon-copy")

            @model.attributes.name
    }

    new ElbAppView()
