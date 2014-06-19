#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view', './template/app', 'i18n!nls/lang.js', 'instance_model', 'kp_upload', 'Design', 'JsonExporter' ], ( PropertyView, template, lang, instance_model, kp_upload, Design, JsonExporter )->

    download = JsonExporter.download

    genDownload = ( name, str ) ->
        ->
            if $("body").hasClass("safari")
              blob = null
            else
              blob = new Blob [str]

            if not blob
              return {
                data : "data://text/plain;,#{str}"
                name : name
              }

            download( blob, name )
            null

    InstanceAppView = PropertyView.extend {
        __kpUpload: null

        events   :
            "click #property-app-keypair" : "keyPairClick"
            "click #property-app-ami" : "openAmiPanel"
            "click .property-btn-get-system-log" : "openSysLogModal"

        kpModalClosed : false

        render : () ->
            data = @model.toJSON()
            data.windows = @model.get( 'osType' ) is 'windows'
            @$el.html template data
            @model.attributes.name

        keyPairClick: ( event ) ->
            @proccessKpStuff()

        proccessKpStuff: ( notOld ) ->
            kpName = @model.get 'keyName'
            isOldKp = false

            if not notOld
                kp = @model.resModel.connectionTargets( "KeypairUsage" )[0]
                isOldDefaultKp = kp and kp.isDefault() and kp.get('appId') is "DefaultKP---#{Design.instance().get('id')}"
                isOldOtherKp = kp and not kp.isDefault()

                isOldKp = isOldDefaultKp or isOldOtherKp

                if isOldKp
                    @model.downloadKp kpName

            if not isOldKp and @model.get( 'osType' ) is 'windows'
                @decryptPassword isOldKp
            else
                @loginPrompt isOldKp



        loginPrompt: ( isOldKp ) ->
            keypair = @model.get 'keyName'

            modal MC.template.modalDownloadKP {
                name    : keypair
                loginCmd: @model.get 'loginCmd'
                isOldKp : isOldKp
                windows : @model.get( 'osType' ) is 'windows'
            }

            me = this
            $( '#keypair-cmd' ).off( 'click' ).on 'click', ( event )->
                if event.currentTarget.select
                    event.currentTarget.select()
                event.stopPropagation()

            false

        decryptPassword : ( isOldKp ) ->
            me = @

            keypair = @model.get 'keyName'
            if not isOldKp
                @model.getPasswordData null, 'check'

            modal MC.template.modalDecryptPassword { name  : keypair, isOldKp: isOldKp }

            $('#modal-wrap').on "closed", ()->
                me.kpModalClosed = true
                null


            $("#do-kp-decrypt").off( 'click' ).on 'click', ( event ) ->
                me.model.getPasswordData me.__kpUpload.getData()

            this.kpModalClosed = false

            false

        updateKPModal : ( action, data, data2, data3 ) ->
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
                $kpPwdInput = $( '#keypair-pwd' )
                kpPwdInput = $kpPwdInput.get(0)

                $kpPwdInput.val( data )
                kpPwdInput.select()
                kpPwdInput.focus()

                $( '#do-kp-decrypt' ).text 'Decrypted'
                $( '.change-pw-recommend' ).show()

            else if action is 'download'
                success = data
                pwd = data2
                kp = data3 or data2

                $( '#keypair-kp-download' ).off('click').on 'click', genDownload "#{@model.get('keyName')}.pem", kp
                $('#keypair-loading').hide()
                $('#keypair-body').show()

                if @model.get( 'osType' ) is 'windows'
                    $('#keypair-pwd-old').val(pwd).off('click').on 'click', () -> this.select()
                    $('#keypair-show').one 'click', () -> $('#keypair-pwd-old').prop 'type', 'input'



        openAmiPanel : ( event ) ->
            this.trigger "OPEN_AMI", $( event.target ).data("uid")
            false

        openSysLogModal : () ->

            instanceId = @model.get('instanceId')

            that = this
            currentRegion = Design.instance().region()
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
