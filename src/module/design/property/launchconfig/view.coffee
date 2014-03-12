#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view', 'text!./template/stack.html', 'event' ], ( PropertyView, template, ide_event ) ->

    template = Handlebars.compile template

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

            #root device
            'click #volume-type-radios input' : 'volumeTypeChecked'
            'keyup #volume-size-ranged' : 'sizeChanged'
            'keyup  #volume-size-ranged' : 'processIops'
            'keyup #iops-ranged' : 'sizeChanged'

        render : () ->

            @$el.html template @model.attributes

            $( "#keypair-select" ).on("click", ".icon-remove", _.bind(this.deleteKP, this) )

            me = this
            # parsley bind
            $( '#volume-size-ranged' ).parsley 'custom', ( val ) ->
                val = + val
                if not val || val > 1024 || val < me.model.attributes.min_volume_size
                    return "Volume size of this rootDevice must in the range of " + me.model.attributes.min_volume_size + "-1024 GB."

            $( '#iops-ranged' ).parsley 'custom', ( val ) ->
                val = + val
                volume_size = parseInt( $( '#volume-size-ranged' ).val(), 10 )
                if val > 4000 || val < 100
                    return 'IOPS must be between 100 and 4000'
                else if( val > 10 * volume_size)
                    return 'IOPS must be less than 10 times of volume size.'


            @model.attributes.name

        publicIpChange : ( event ) ->
            @model.setPublicIp event.currentTarget.checked
            null

        lcNameChange : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            id = @model.get 'uid'
            MC.validate.preventDupname target, id, name, 'LaunchConfiguration'

            if target.parsley 'validate'
                @model.setName name
                @setTitle name

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
                notification "error", "KeyPair with the same name already exists."
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
                    body    : "<p class='modal-text-major'>Are you sure you want to delete #{$li.text()}</p><p class='modal-text-minor'>Resources using this key pair will change automatically to use DefaultKP.</p>"
                # Ask for confirm
                modal MC.template.modalApp data
                $("#btn-confirm").one "click", ()->
                    removeKP()
                    modal.close()
            else
                removeKP()

            return false

        ###### root device #########
        volumeTypeChecked : ( event ) ->
            @processIops()
            if($('#volume-type-radios input:checked').val() is 'radio-standard')
                $( '#iops-group' ).hide()
                @model.setVolumeTypeStandard()
            else
                $( '#iops-group' ).show()
                @model.setVolumeTypeIops $( '#iops-ranged' ).val()
            @sizeChanged()

        processIops: ( event ) ->
            size = parseInt $( '#volume-size-ranged' ).val(), 10
            opsCheck = $( '#radio-iops' ).is ':checked'
            if size >= 10
                @enableIops()
            else if not opsCheck
                @disableIops()

            null

        enableIops: ->
            $( '#volume-type-radios > div' )
                .last()
                .data( 'tooltip', '' )
                .find( 'input' )
                .removeAttr( 'disabled' )

        disableIops: ->
            $( '#volume-type-radios > div' )
                .last()
                .data( 'tooltip', 'Volume size must be at least 10 GB to use Provisioned IOPS volume type.' )
                .find( 'input' )
                .attr( 'disabled', '' )


        sizeChanged : ( event ) ->
            volumeSize = parseInt $( '#volume-size-ranged' ).val(), 10
            iopsValidate = true
            volumeValidate = $( '#volume-size-ranged' ).parsley 'validate'
            iopsEnabled = $( '#radio-iops' ).is ':checked'
            if iopsEnabled
                iopsValidate = $( '#iops-ranged' ).parsley 'validate'
            if volumeValidate and iopsValidate
                this.trigger 'VOLUME_SIZE_CHANGED', volumeSize
                if iopsEnabled
                    @model.setVolumeIops $( '#iops-ranged' ).val()
            null

    }

    new LanchConfigView()
