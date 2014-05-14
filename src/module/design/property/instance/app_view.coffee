#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view', './template/app', 'i18n!nls/lang.js', 'instance_model', 'kp_upload' ], ( PropertyView, template, lang, instance_model, kp_upload )->

    InstanceAppView = PropertyView.extend {
        __kpUpload: null
        __kpModal: null

        events   :
            "click #property-app-keypair" : "keyPairClick"
            "click #property-app-ami" : "openAmiPanel"
            "click .property-btn-get-system-log" : "openSysLogModal"

        kpModalClosed : false

        initialize: () ->


        render : () ->
            @$el.html template @model.attributes
            @model.attributes.name

        keyPairClick: ( event ) ->
            if @model.get( 'osType' ) is 'windows'
                @decryptPassword event
            else
                @loginPrompt event

        loginPrompt: ( event ) ->
            keypair = $( event.currentTarget ).html()
            modal MC.template.modalDownloadKP name: keypair, loginCmd: @model.get 'loginCmd'

            me = this
            $( '#keypair-cmd' ).off( 'click' ).on 'click', ( event )->
                if event.currentTarget.select
                    event.currentTarget.select()
                event.stopPropagation()

            false

        decryptPassword : ( event ) ->
            me = @

            keypair = $( event.currentTarget ).html()
            @model.getPasswordData null, 'check'
            @__kpModal = MC.template.modalDecryptPassword { name  : keypair }

            modal @__kpModal


            $('#modal-wrap').on "closed", ()->
                me.kpModalClosed = true
                null


            $("#do-kp-decrypt").off( 'click' ).on 'click', ( event ) ->
                me.model.getPasswordData btoa me.__kpUpload.getData()

            this.kpModalClosed = false

            false

        updateKPModal : ( action, data ) ->
            if this.kpModalClosed
                return

            if action is 'check'
                if data
                    @__kpUpload and @__kpUpload.remove()
                    @__kpUpload = new kp_upload()
                    @__kpUpload.on 'load', () ->
                        $("#do-kp-decrypt").prop 'disabled', false

                    $( '#modal-box .import-zone' ).html @__kpUpload.render().el
                    $( '#modal-box .decrypt-action' ).show()
                else
                    $( '#modal-box .import-zone' ).html ''
                    $( '#modal-box .no-password' ).show()


            else if action is 'got'
                $("#do-kp-decrypt").prop 'disabled', true
                $( '#modal-box .keypair-pwd' )
                    .val( data )
                    .select()


        openAmiPanel : ( event ) ->
            this.trigger "OPEN_AMI", $( event.target ).data("uid")
            false

        openSysLogModal : () ->

            instanceId = @model.get('instanceId')

            that = this
            currentRegion = MC.canvas_data.region
            instance_model.GetConsoleOutput {sender: that}, $.cookie('usercode'), $.cookie('session_id'), currentRegion, instanceId

            modal MC.template.modalInstanceSysLog {
                instance_id: instanceId,
                log_content: ''
            }, true

            that.off('EC2_INS_GET_CONSOLE_OUTPUT_RETURN').on 'EC2_INS_GET_CONSOLE_OUTPUT_RETURN', (result) ->

                if !result.is_error
                    console.log(result.resolved_data)
                that.refreshSysLog(result.resolved_data)

            return false

        refreshSysLog : (result) ->

            $('#modal-instance-sys-log .instance-sys-log-loading').hide()

            if result and result.output

                logContent = MC.base64Decode(result.output)
                $contentElem = $('#modal-instance-sys-log .instance-sys-log-content')

                $contentElem.html MC.template.convertBreaklines({content:logContent})
                $contentElem.show()

            else

                $('#modal-instance-sys-log .instance-sys-log-info').show()

            modal.position()

    }

    new InstanceAppView()
