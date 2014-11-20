#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view', './template/app', 'i18n!/nls/lang.js', 'ApiRequest', 'kp_upload', 'Design', 'JsonExporter' ], ( PropertyView, template, lang, ApiRequest, kp_upload, Design, JsonExporter )->

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

        render : () ->
            data = @model.toJSON()
            data.windows = @model.get( 'osType' ) is 'windows'
            @$el.html template data
            @model.attributes.name

        keyPairClick: ( event ) ->
            @proccessKpStuff()

        proccessKpStuff: ( notOld ) ->
            # if not notOld
            #     kp = @model.resModel.connectionTargets( "KeypairUsage" )[0]
            #     isOldDefaultKp = kp and kp.isDefault() and kp.get('appId') is "DefaultKP---#{Design.instance().get('id')}"
            #     isOldOtherKp = kp and not kp.isDefault()

            #     isOldKp = isOldDefaultKp or isOldOtherKp

            #     if isOldKp
            #         @model.downloadKp kpName

            if not isOldKp and @model.get( 'osType' ) is 'windows'
                @decryptPassword()
            else
                @loginPrompt()



        loginPrompt: () ->
            keypair = @model.get 'keyName'

            modal MC.template.modalDownloadKP {
                name    : keypair
                loginCmd: @model.get 'loginCmd'
                isOldKp : false
                windows : @model.get( 'osType' ) is 'windows'
            }

            me = this
            $( '#keypair-cmd' ).off( 'click' ).on 'click', ( event )->
                if event.currentTarget.select
                    event.currentTarget.select()
                event.stopPropagation()

            false

        decryptPassword : () ->
            modal MC.template.modalDecryptPassword { name:@model.get('keyName'), isOldKp:false }
            @kpModalClosed = false

            me = @
            $('#modal-wrap').on "closed", ()-> me.kpModalClosed = true; return

            @model.getPassword().then ( data )->
                @updateKPModal("check", !!data)
            , ()->
                notification 'error', lang.NOTIFY.ERR_GET_PASSWD_FAILED

            $("#do-kp-decrypt").off( 'click' ).on 'click', ( event ) ->
                me.model.getPassword( me.__kpUpload.getData() ).then ( data )->
                    me.updateKPModal("got", data)
                , ()->
                    notification 'error', lang.NOTIFY.ERR_GET_PASSWD_FAILED
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

            modal MC.template.modalInstanceSysLog {
                instance_id: instanceId,
                log_content: ''
            }, true

            that = this
            ApiRequest("ins_GetConsoleOutput",{
                region      : Design.instance().region()
                instance_id : instanceId
            }).then ( data )->
                that.refreshSysLog( data.GetConsoleOutputResponse )
            , ()->
                that.refreshSysLog()
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
