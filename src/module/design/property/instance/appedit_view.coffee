#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view',
         'text!./template/app_edit.html',
         'text!./template/app_edit_ami_list.html',
         'i18n!nls/lang.js',
         'text!./template/ip_list.html'
], ( PropertyView, template, ami_list_template, lang, ip_list_template ) ->

    template          = Handlebars.compile template
    ip_list_template  = Handlebars.compile ip_list_template
    ami_list_template = Handlebars.compile ami_list_template

    InstanceView = PropertyView.extend {

        events :
            'change #property-instance-count'     : "countChange"
            'OPTION_CHANGE #instance-type-select' : "instanceTypeSelect"
            'click #property-ami'                 : "openAmiPanel"


        render : ( ) ->
            # Render
            @$el.html template @model.attributes

            @updateInstanceList()

            # Return title of property
            @model.attributes.name

        openAmiPanel : ( event ) ->
            this.trigger "OPEN_AMI", $( event.currentTarget ).data("uid")
            false

        updateInstanceList : () ->
            $("#prop-appedit-ami-list").html ami_list_template @model.attributes
            null

        countChange : ( event ) ->
            target = $ event.currentTarget

            target.parsley 'custom', ( val ) ->
                if isNaN( val ) or val > 99 or val < 1
                    return 'This value must be >= 1 and <= 99'

            if not target.parsley 'validate'
                return

            val = +target.val()
            @model.setCount val
            # @setEditableIP val == 1

            @updateInstanceList()
            null

        instanceTypeSelect : ( event ) ->
            # TODO :
            # type = $("#instance-type-select").find(".selected").attr("data-id")
            # @model.setInstanceType type
            null

    }

    new InstanceView()
