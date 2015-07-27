#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view', './template/stack', './template/stack_mesos', 'event', 'constant', 'i18n!/nls/lang.js', 'kp_dropdown' ], ( PropertyView, TplLc, TplMesos, ide_event, constant, lang, kp ) ->

    iopsMax = 20000

    LanchConfigView = PropertyView.extend {

        events   :
            'change .launch-configuration-name'           : 'lcNameChange'
            'change #property-res-desc'                   : 'onChangeDescription'
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

            'change .mesos-attr'              : 'setMesosAttribute'
            'REMOVE_ROW .multi-input'         : 'setMesosAttribute'
            'click #add-ma-item-outside'      : 'addMesosAttrItem'

        watchChangedInAppEdit: ->
            if @resModel.changedInAppEdit()
                @$('.property-warning-block').show()
            else
                @$('.property-warning-block').hide()

        render : () ->
            tpl = if @resModel.isMesos() then TplMesos else TplLc
            @$el.html tpl @model.toJSON()

            kpDropdown = new kp(resModel: @resModel)

            @addSubView kpDropdown
            @$('#kp-placeholder').html kpDropdown.render().el

            me = this
            # parsley bind
            $( '#volume-size-ranged' ).parsley 'custom', ( val ) ->
                val = + val
                if not val || val > 16384 || val < me.model.attributes.min_volume_size
                    return sprintf lang.PARSLEY.VOLUME_SIZE_OF_ROOTDEVICE_MUST_IN_RANGE, me.model.attributes.min_volume_size

            $( '#iops-ranged' ).parsley 'custom', ( val ) ->
                val = + val
                volume_size = parseInt( $( '#volume-size-ranged' ).val(), 10 )
                if val > iopsMax || val < 100
                    return lang.PARSLEY.IOPS_MUST_BETWEEN_100_4000
                else if( val > 10 * volume_size)
                    return lang.PARSLEY.IOPS_MUST_BE_LESS_THAN_10_TIMES_OF_VOLUME_SIZE

            @watchChangedInAppEdit()

            @model.attributes.name

        addMesosAttrItem: ( e ) ->
            @$( '#mesos-attribute' ).find( '.icon-add' ).eq(0).click()
            false

        setMesosAttribute: ( event ) ->
            attr = {}

            @$( '#mesos-attribute' ).find( '.multi-ipt-row:not(.template)' ).each ->
                $inputs = $(@).find( '.input' )
                key = $inputs[ 0 ].value.trim()
                value = $inputs[ 1 ].value

                if key.length
                    attr[ key ] = value

            @resModel.setMesosAttributes attr

        onChangeDescription : (event) -> @model.setDesc $(event.currentTarget).val()

        changeVolumeType : ( event ) ->
            $this = $( event.currentTarget )

            if $this.is(":disabled") then return

            type = $this.val()

            $("#iops-group").toggle type is "io1"

            if type is "io1"
                # Init iops
                volumeSize = parseInt $( '#volume-size-ranged' ).val(), 10

                iops = volumeSize * 10
                if iops > iopsMax then iops = iopsMax

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

        publicIpChange : ( event ) ->
            @model.setPublicIp event.currentTarget.checked
            null

        lcNameChange : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if MC.aws.aws.checkResName( @model.get('uid'), target, "LaunchConfiguration" )
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
                notification "error", lang.NOTIFY.WARN_KEYPAIR_NAME_ALREADY_EXISTS
                return result

        updateKPSelect : () ->
            # Add remove icon to the newly created item
            $("#keypair-select").find(".item:last-child").append('<span class="icon-remove"></span>')

        openAmiPanel : ( event ) ->
            @trigger "OPEN_AMI", $("#property-ami").attr("data-uid")
            null

        disableUserDataInput : ( flag ) ->

            $userDataInput = $('#property-instance-user-data')

            if flag is true
                $userDataInput.attr('disabled', 'disabled')
                $userDataInput.addClass('tooltip').attr('data-tooltip', lang.PROP.INSTANCE_USER_DATA_DISABLE)
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
