#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view',
         '../instance/view'
         './template/app',
         './template/ami_list',
         'i18n!/nls/lang.js'
], ( PropertyView, instance_view, template, ami_list_template, lang ) ->

    InstanceView = PropertyView.extend {

        events :
            'change #property-instance-count'     : "countChange"
            'click #property-ami'                 : "openAmiPanel"

            'OPTION_CHANGE #instance-type-select'     : "instanceTypeSelect"
            'change #property-instance-ebs-optimized' : 'ebsOptimizedSelect'

            'click .toggle-eip'                         : 'setEip'
            'click #instance-ip-add'                    : "addIp"
            'click #property-network-list .icon-remove' : "removeIp"
            'change .input-ip'                          : 'syncIPList'

            'change #property-instance-enable-cloudwatch' : 'cloudwatchSelect'
            'change #property-instance-source-check'      : 'sourceCheckChange'

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
                    return lang.ide.PARSLEY_THIS_VALUE_MUST_BETWEEN_1_99

            if not target.parsley 'validate'
                return

            val = +target.val()
            @model.setCount val

            @updateInstanceList()
            @setEditableIP( val is 1 )
            null

        ebsOptimizedSelect : ( event )->
            @model.setEbsOptimized event.target.checked
            null

        instanceTypeSelect  : instance_view.instanceTypeSelect

        cloudwatchSelect : instance_view.cloudwatchSelect
        sourceCheckChange : instance_view.sourceCheckChange

        addIp               : instance_view.addIp
        removeIp            : instance_view.removeIp
        setEip              : instance_view.setEip
        syncIPList          : instance_view.syncIPList
        refreshIPList       : instance_view.refreshIPList
        updateIPAddBtnState : instance_view.updateIPAddBtnState
        setEditableIP       : instance_view.setEditableIP
        validateIpItem      : instance_view.validateIpItem
        bindIpItemValidate  : instance_view.bindIpItemValidate


    }

    new InstanceView()
