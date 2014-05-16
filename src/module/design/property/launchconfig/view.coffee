#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view', './template/stack', 'event', 'constant', 'i18n!nls/lang.js', 'kp' ], ( PropertyView, template, ide_event, constant, lang, kp ) ->

    LanchConfigView = PropertyView.extend {

        events   :
            'change .launch-configuration-name'           : 'lcNameChange'
            'change .instance-type-select'                : 'instanceTypeSelect'
            'change #property-instance-ebs-optimized'     : 'ebsOptimizedSelect'
            'change #property-instance-enable-cloudwatch' : 'cloudwatchSelect'
            'change #property-instance-user-data'         : 'userdataChange'
            'change #property-instance-public-ip'         : 'publicIpChange'
            'OPTION_CHANGE #instance-type-select'         : "instanceTypeSelect"
            'OPTION_CHANGE #keypair-select'               : "setKP"
            'EDIT_UPDATE #keypair-select'                 : "addKP"
            "EDIT_FINISHED #keypair-select"               : "updateKPSelect"

            'click #property-ami'                         : 'openAmiPanel'

            'click #volume-type-radios input' : 'changeVolumeType'
            'keyup #iops-ranged'              : 'changeIops'
            'keyup #volume-size-ranged'       : 'sizeChanged'

        changeVolumeType : ( event ) ->
            $this = $( event.currentTarget )
            if $this.is(":disabled") then return

            $("#iops-group").toggle( $this.attr("id") is "radio-iops" )

            if $this.attr("id") is "radio-iops"
                # Init iops
                volumeSize = parseInt $( '#volume-size-ranged' ).val(), 10
                iops = volumeSize * 10
                $("#iops-ranged").val( iops ).keyup()
            else
                # Reset standard
                @model.setIops("")
                $("#iops-ranged").val("")

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
            @$('#kp-placeholder').html kp.loadModule(instanceModel).el

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

            # currentStateData = @model.getStateData()

            # if currentStateData and _.isArray(currentStateData) and currentStateData.length
            #     @disableUserDataInput(true)
            # else
            #     @disableUserDataInput(false)

            @model.attributes.name

        publicIpChange : ( event ) ->
            @model.setPublicIp event.currentTarget.checked
            null

        lcNameChange : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if @checkResName( target, "LaunchConfiguration" )
                @model.setName name
                @setTitle name
            null

        instanceTypeSelect : ( event, value )->

            has_ebs = @model.setInstanceType value
            $ebs = $("#property-instance-ebs-optimized")
            $ebs.closest(".property-control-group").toggle has_ebs
            if not has_ebs
                $ebs.prop "checked", false

        ebsOptimizedSelect : ( event ) ->
            @model.setEbsOptimized event.target.checked
            null

        cloudwatchSelect : ( event ) ->
            @model.setCloudWatch event.target.checked
            $("#property-cloudwatch-warn").toggle( $("#property-instance-enable-cloudwatch").is(":checked") )

        userdataChange : ( event ) ->
            @model.setUserData event.target.value

        setKP : ( event, id ) ->
            @model.setKP id

        addKP : ( event, id ) ->
            result = @model.addKP id
            if not result
                notification "error", lang.ide.NOTIFY_MSG_WARN_KEYPAIR_NAME_ALREADY_EXISTS
                return result

        updateKPSelect : () ->
            # Add remove icon to the newly created item
            $("#keypair-select").find(".item:last-child").append('<span class="icon-remove"></span>')

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
                    body    : "<p class='modal-text-major'>Are you sure to delete #{$li.text()}?</p><p class='modal-text-minor'>Resources using this key pair will change automatically to use DefaultKP.</p>"
                # Ask for confirm
                modal MC.template.modalApp data
                $("#btn-confirm").one "click", ()->
                    removeKP()
                    modal.close()
            else
                removeKP()

            return false

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

    new LanchConfigView()
