#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view',
         './template/stack',
         'i18n!nls/lang.js', 'constant', 'kp_dropdown' ], ( PropertyView, template, lang, constant, kp ) ->

    noop = ()-> null

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

            'click .toggle-eip'                         : 'setEip'
            'click #instance-ip-add'                    : "addIp"
            'click #property-network-list .icon-remove' : "removeIp"
            'change .input-ip'                          : 'syncIPList'

            'click #volume-type-radios input' : 'changeVolumeType'
            'keyup #iops-ranged'              : 'changeIops'
            'keyup #volume-size-ranged'       : 'sizeChanged'

        changeVolumeType : ( event ) ->
            $this = $( event.currentTarget )

            if $this.is(":disabled") then return

            type = $this.val()

            $("#iops-group").toggle type is "io1"

            if type is "io1"
                # Init iops
                volumeSize = parseInt $( '#volume-size-ranged' ).val(), 10
                iops = volumeSize * 10
                $("#iops-ranged").val( iops ).keyup()
            else
                # Reset standard
                @model.setIops("")
                $("#iops-ranged").val("")

            @model.setVolumeType type

            null

        changeIops : ()->
            if $( '#iops-ranged' ).parsley( 'validate' )
                @model.setIops( $( '#iops-ranged' ).val() )
            null

        sizeChanged : ( event ) ->
            if not $( '#volume-size-ranged' ).parsley( 'validate' )
                return

            volumeSize = parseInt $( '#volume-size-ranged' ).val(), 10

            @model.setVolumeSize( volumeSize )

            if volumeSize < 10
                @model.setIops("")
                iopsDisabled = true

            # Toggle IOPS input
            $iops = $( '#volume-type-radios' ).children("div").last()
                .toggleClass("tooltip", iopsDisabled)
                .find( 'input' )

            if iopsDisabled
                $iops.attr("disabled", "disabled")
                $("#radio-standard").click()
                $("#iops-group").hide()
            else
                $iops.removeAttr( 'disabled' )


            # Adjust IOPS if it exceed limits
            iops = parseInt( $("#iops-ranged").val(), 10 ) || 0
            if iops
                if iops > volumeSize * 10
                    iops = volumeSize * 10
                    $("#iops-ranged").val( iops )
                $("#iops-ranged").keyup()
            null

        render : () ->
            @$el.html template @model.attributes
            instanceModel = Design.instance().component( @model.get 'uid' )

            kpDropdown = new kp(resModel: instanceModel)
            @$('#kp-placeholder').html kpDropdown.render().el
            @addSubView kpDropdown

            @refreshIPList()

            me = this
            # parsley bind
            $( '#volume-size-ranged' ).parsley 'custom', ( val ) ->
                val = + val
                if not val || val > 1024 || val < me.model.attributes.min_volume_size
                    return sprintf lang.ide.PARSLEY_VOLUME_SIZE_OF_ROOTDEVICE_MUST_IN_RANGE, me.model.attributes.min_volume_size

            $( '#iops-ranged' ).parsley 'custom', ( val ) ->
                val = + val
                volume_size = parseInt( $( '#volume-size-ranged' ).val(), 10 )
                if val > 4000 || val < 100
                    return lang.ide.PARSLEY_IOPS_MUST_BETWEEN_100_4000
                else if( val > 10 * volume_size)
                    return lang.ide.PARSLEY_IOPS_MUST_BE_LESS_THAN_10_TIMES_OF_VOLUME_SIZE

            #

            # currentStateData = @model.getStateData()

            # if currentStateData and _.isArray(currentStateData) and currentStateData.length
            #     @disableUserDataInput(true)
            # else
            #     @disableUserDataInput(false)

            @model.attributes.name

        instanceNameChange : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if @checkResName( target, "Instance" )
                @model.setName name
                @setTitle name
            null

        countChange : ( event ) ->
            target = $ event.currentTarget

            that = this

            target.parsley 'custom', ( val ) ->
                if isNaN( val ) or val > 99 or val < 1
                    return lang.ide.PARSLEY_THIS_VALUE_MUST_BETWEEN_1_99

            if target.parsley 'validate'

                this.refreshIPList()

                val = +target.val()
                @model.setCount val
                $(".property-instance-name-wrap").toggleClass("single", val == 1)
                $("#property-instance-name-count").text val-1
                @setEditableIP val == 1

        setEditableIP : ( enable ) ->
            $parent = $("#property-network-list")

            if enable
                $parent.find(".input-ip-wrap").removeClass("disabled")
                       .find(".name").data("tooltip", lang.ide.PROP_INSTANCE_IP_MSG_1)
                       .find(".input-ip").prop("disabled", "")

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
            @model.setMonitoring event.target.checked
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


        updateKPSelect : () ->
            # Add remove icon to the newly created item
            $("#keypair-select").find(".item:last-child").append('<span class="icon-remove"></span>')
            null

        openAmiPanel : ( event ) ->
            @trigger "OPEN_AMI", $("#property-ami").attr("data-uid")
            null


        validateIpItem : ( $item ) ->

            that = this
            $item.parsley "custom", ( val ) ->
                validDOM         = $item
                inputValue       = validDOM.val()
                inputValuePrefix = validDOM.siblings(".input-ip-prefix").text()
                currentInputIP   = inputValuePrefix + inputValue
                prefixAry        = inputValuePrefix.split('.')

                ###### validation format
                ipIPFormatCorrect = false
                # for 10.0.0.
                if prefixAry.length is 4
                    if inputValue is 'x'
                        ipIPFormatCorrect = true
                    else if MC.validate 'ipaddress', (inputValuePrefix + inputValue)
                        ipIPFormatCorrect = true
                # for 10.0.
                else
                    if inputValue is 'x.x'
                        ipIPFormatCorrect = true
                    else if MC.validate 'ipaddress', (inputValuePrefix + inputValue)
                        ipIPFormatCorrect = true

                if !ipIPFormatCorrect
                    return 'Invalid IP address'
                else
                    result = that.model.isValidIp( currentInputIP )
                    if result isnt true
                        return result

            result = $item.parsley("validate")
            $item.parsley("custom", noop)
            return result

        addIp : () ->
            if $("#instance-ip-add").hasClass("disabled")
                return

            @model.addIp()
            @refreshIPList()
            null

        removeIp : ( event ) ->

            $li = $(event.currentTarget).closest("li")
            index = $li.index()
            $li.remove()

            @model.removeIp index
            @updateIPAddBtnState( true )
            null

        setEip : ( event ) ->
            $target = $(event.currentTarget)
            index   = $target.closest("li").index()
            attach  = not $target.hasClass("associated")

            if attach
                tooltip = lang.ide.PROP_INSTANCE_IP_MSG_4
            else
                tooltip = lang.ide.PROP_INSTANCE_IP_MSG_3
            $target.toggleClass("associated", attach).data("tooltip", tooltip)

            @model.attachEip index, attach
            null

        # This function is used to save IP List to model
        syncIPList : (event) ->

            ipItems = $('#property-network-list .input-ip-item')
            $target = $( event.currentTarget )

            if not @validateIpItem( $target ) then return

            ipVal = $target.val()
            ip = $target.siblings( ".input-ip-prefix" ).text() + ipVal
            autoAssign = ipVal is "x" or ipVal is "x.x"

            @model.setIp $target.closest("li").index(), ip, autoAssign
            null

        # This function is used to display IP List
        refreshIPList : () ->
            if not @model.attributes.eni
                return

            $( '#property-network-list' ).html( MC.template.propertyIpList( @model.attributes.eni.ips ) )

            @updateIPAddBtnState()
            null

        updateIPAddBtnState : ( enabled ) ->
            if enabled is undefined
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

        disableUserDataInput : ( flag ) ->

            $userDataInput = $('#property-instance-user-data')

            if flag is true
                $userDataInput.attr('disabled', 'disabled')
                $userDataInput.addClass('tooltip').attr('data-tooltip', lang.ide.PROP_INSTANCE_USER_DATA_DISABLE)
                # $userDataInput.val('')
                # @userdataChange({
                #     target: {
                #         value: ''
                #     }
                # })
            else if flag is false
                $userDataInput.removeAttr('disabled')
                $userDataInput.removeClass('tooltip').removeAttr('data-tooltip')
    }

    new InstanceView()
