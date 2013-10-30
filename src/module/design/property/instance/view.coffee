#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'event',
         'i18n!nls/lang.js' ], ( PropertyView, template, ide_event, lang ) ->

    template =  Handlebars.compile template

    InstanceView = PropertyView.extend {

        events   :
            'change .instance-name'                       : 'instanceNameChange'
            'change #property-instance-count'             : 'countChange'
            'change #property-instance-ebs-optimized'     : 'ebsOptimizedSelect'
            'change #property-instance-enable-cloudwatch' : 'cloudwatchSelect'
            'change #property-instance-user-data'         : 'userdataChange'
            'change #property-instance-ni-description'    : 'eniDescriptionChange'
            'change #property-instance-source-check'      : 'sourceCheckChange'
            'change #property-instance-public-ip'         : 'publicIpChange'
            'OPTION_CHANGE #instance-type-select'         : "instanceTypeSelect"
            'OPTION_CHANGE #tenancy-select'               : "tenancySelect"

            'click #property-ami' : 'openAmiPanel'

            'OPTION_CHANGE #keypair-select'      : "setKP"
            'EDIT_UPDATE #keypair-select'        : "addKP"
            'click #keypair-select .icon-remove' : "deleteKP"
            "EDIT_FINISHED #keypair-select"      : "updateKPSelect"

            'click .toggle-eip'                         : 'setEIP'
            'click #instance-ip-add'                    : "addIP"
            'click #property-network-list .icon-remove' : "removeIP"
            'change .input-ip'                          : 'syncIPList'


        render : () ->

            # TODO : Remove following 3 lines
            defaultVPCId = MC.aws.aws.checkDefaultVPC()
            if defaultVPCId
                this.model.attributes.component.resource.VpcId = defaultVPCId

            @$el.html template @model.attributes

            @refreshIPList()

            @model.attributes.name

        instanceNameChange : ( event ) ->

            target = $ event.currentTarget
            name = target.val()
            id = @model.get 'uid'

            MC.validate.preventDupname target, id, name, 'Instance'


            if target.parsley 'validate'
                @model.setName name
                @setTitle name
            null

        countChange : ( event ) ->
            target = $ event.currentTarget

            target.parsley 'custom', ( val ) ->
                if isNaN( val ) or val > 99 or val < 1
                    return 'This value must be >= 1 and <= 99'

            if target.parsley 'validate'
                val = +target.val()
                @model.setCount val
                $(".property-instance-name-wrap").toggleClass("single", val == 1)
                $("#property-instance-name-count").text val
                @setEditableIP val == 1

        setEditableIP : ( enable ) ->
            $parent = $("#property-network-list")

            if enable
                $parent.find(".input-ip-wrap").removeClass("disabled")
                       .find(".name").data("tooltip", lang.ide.PROP_INSTANCE_IP_MSG_1)
                       .find(".input-ip").removeAttr("disabled")

            else
                $parent.find(".input-ip-wrap").addClass("disabled")
                       .find(".name").data("tooltip", lang.ide.PROP_INSTANCE_IP_MSG_2)
                       .find(".input-ip").attr("disabled", "disabled")
            null

        instanceTypeSelect : ( event, value )->

            canset = @model.canSetInstanceType value
            if canset isnt true
                notification "error", canset
                event.preventDefault()
                return

            has_ebs = @model.setInstanceType value
            $ebs = $("#property-instance-ebs-optimized")
            $ebs.closest(".property-control-group").toggle has_ebs
            if not has_ebs
                $ebs.prop "checked", false

            @refreshIPList()

        ebsOptimizedSelect : ( event ) ->
            @model.setEbsOptimized event.target.checked
            null

        tenancySelect : ( event, value ) ->
            $type = $("#instance-type-select")
            $t1   = $type.find("[data-id='t1.micro']")

            if $t1.length
                show = value isnt "dedicated"
                $t1.toggle( show )

                if $t1.hasClass("selected") and not show
                    $type.find(".item:not([data-id='t1.micro'])").eq(0).click()

            @model.setTenancy value
            null

        cloudwatchSelect : ( event ) ->
            @model.setCloudWatch event.target.checked
            $("#property-cloudwatch-warn").toggle( $("#property-instance-enable-cloudwatch").is(":checked") )

        userdataChange : ( event ) ->
            @model.setUserData event.target.value
            null

        eniDescriptionChange : ( event ) ->
            @model.setEniDescription event.target.value
            null

        sourceCheckChange : ( event ) ->
            @model.setSourceCheck event.target.checked
            null

        publicIpChange : ( event ) ->
            @model.setPublicIp event.target.checked
            null

        setKP : ( event, id ) ->
            @model.setKP id
            null

        addKP : ( event, id ) ->
            result = @model.addKP id
            if not result
                notification "error", "KeyPair with the same name already exists."
                return result

        updateKPSelect : () ->
            # Add remove icon to the newly created item
            $("#keypair-select").find(".item:last-child").append('<span class="icon-remove"></span>')
            null

        openAmiPanel : ( event ) ->
            @trigger "OPEN_AMI", $("#property-ami").attr("data-uid")
            null


        deleteKP : ( event ) ->
            me = this
            $li = $(event.currentTarget).closest("li")

            selected = $li.hasClass("selected")
            using = if using is "true" then true else selected

            removeKP = () ->

                $li.remove()
                # If deleting selected kp, select the first one
                if selected
                    $("#keypair-select").find(".item").eq(0).click()

                me.model.deleteKP $li.attr("data-id")

            if using
                data =
                    title   : "Delete Key Pair"
                    confirm : "Delete"
                    color   : "red"
                    body    : "<p class='modal-text-major'>Are you sure you want to delete #{$li.text()}</p><p class='modal-text-minor'>Resources using this key pair will change automatically to use DefaultKP.</p>"
                # Ask for confirm
                modal MC.template.modalApp data
                $("#btn-confirm").one "click", ()->
                    removeKP()
                    modal.close()
            else
                removeKP()

            return false


        addIP : () ->
            if $("#instance-ip-add").hasClass("disabled")
                return

            data = @model.addIP()
            $('#property-network-list').append MC.template.propertyIpListItem( data )
            @updateIPAddBtnState()
            null

        removeIP : ( event ) ->

            $li = $(event.currentTarget).closest("li")
            index = $li.index()
            $li.remove()

            @model.removeIP index
            @updateIPAddBtnState()
            null

        setEIP : ( event ) ->
            $target = $(event.currentTarget)
            index   = $target.closest("li").index()
            attach  = not $target.hasClass("associated")

            @model.attachEIP index, attach
            null

        # This function is used to save IP List to model
        syncIPList: () ->
            currentAvailableIPAry = _.map $('#property-network-list li'), (ipInputItem) ->
                $item   = $(ipInputItem)
                prefix  = $item.find(".input-ip-prefix").text()
                value   = $item.find(".input-ip").val()
                has_eip = $item.find(".input-ip-eip-btn").hasClass("associated")

                {
                    ip     : prefix + value
                    eip    : has_eip
                    suffix : value
                }

            @model.setIPList currentAvailableIPAry
            null

        # This function is used to display IP List
        refreshIPList : ( event ) ->
            if not @model.attributes.eni_ips
                return

            html = ""
            for ip in @model.attributes.eni_ips
                html += MC.template.propertyIpListItem ip

            $( '#property-network-list' ).html( html )
            @updateIPAddBtnState()
            null

        updateIPAddBtnState : ()->
            enabled = @model.canAddIP()

            if enabled is true
                tooltip = "Add IP Address"
            else
                if _.isString enabled
                    tooltip = enabled
                else
                    tooltip = "Cannot add IP address"
                enabled = false

            $("#instance-ip-add").toggleClass("disabled", !enabled).data("tooltip", tooltip)
            null
    }

    new InstanceView()
