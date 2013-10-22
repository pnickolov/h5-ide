#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view',
         'text!./template/app_edit.html' ], ( PropertyView, template ) ->

    template = Handlebars.compile template

    InstanceView = PropertyView.extend {

        events : {}

        render : ( ) ->

            # Render
            @$el.html( template() )

            # Return title of property
            return "Instance App Edit"
    }

    new InstanceView()
