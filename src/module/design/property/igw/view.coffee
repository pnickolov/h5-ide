#############################
#  View(UI logic) for design/property/igw
#############################

define [ '../base/view', 'text!./template/stack.html' ], ( PropertyView, template ) ->

    template = Handlebars.compile template

    IGWView = PropertyView.extend {
        render : () ->
            console.log 'property:igw render'
            @$el.html template()
            "Internet-gateway"
    }

    new IGWView()
