#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view',
         'text!./template/app_edit.html',
         'i18n!nls/lang.js',
         'text!./template/ip_list.html'
], ( PropertyView, template, lang, ip_list_template ) ->

    template         = Handlebars.compile template
    ip_list_template = Handlebars.compile ip_list_template

    InstanceView = PropertyView.extend {

        events :
            'OPTION_CHANGE #instance-type-select' : "instanceTypeSelect"
            'click #property-ami' : "openAmiPanel"


        render : ( ) ->
            # Render
            @$el.html template @model.attributes

            # Return title of property
            @model.attributes.name

        openAmiPanel : ( event ) ->
            this.trigger "OPEN_AMI", $( event.currentTarget ).data("uid")
            false
    }

    new InstanceView()
