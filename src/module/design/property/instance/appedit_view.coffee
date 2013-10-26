#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view',
         './view',
         'text!./template/app_edit.html',
         'text!./template/app_edit_ami_list.html',
         'i18n!nls/lang.js'
], ( PropertyView, stack_view, template, ami_list_template, lang ) ->

    template          = Handlebars.compile template
    ami_list_template = Handlebars.compile ami_list_template

    InstanceView = PropertyView.extend {

        events :
            'change #property-instance-count'     : "countChange"
            'click #property-ami'                 : "openAmiPanel"

            'OPTION_CHANGE #instance-type-select'     : "instanceTypeSelect"
            'change #property-instance-ebs-optimized' : 'ebsOptimizedSelect'

            'click .toggle-eip'                         : 'setEIP'
            'click #instance-ip-add'                    : "addIP"
            'click #property-network-list .icon-remove' : "removeIP"
            'change .input-ip'                          : 'syncIPList'



        render : ( ) ->
            # Render
            @$el.html template @model.attributes

            @updateInstanceList()
            @refreshIPList()

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

        ebsOptimizedSelect : ( event )->
            @model.setEbsOptimized event.target.checked
            null

        instanceTypeSelect  : stack_view.instanceTypeSelect

        addIP               : stack_view.addIP
        removeIP            : stack_view.removeIP
        setEIP              : stack_view.setEIP
        syncIPList          : stack_view.syncIPList
        refreshIPList       : stack_view.refreshIPList
        updateIPAddBtnState : stack_view.updateIPAddBtnState


    }

    new InstanceView()
