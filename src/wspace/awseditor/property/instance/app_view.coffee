#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view', './template/app', 'i18n!/nls/lang.js', 'ApiRequest', 'kp_upload', 'Design', 'JsonExporter', "UI.modalplus" ], ( PropertyView, template, lang, ApiRequest, kp_upload, Design, JsonExporter, modalPlus )->

    download = JsonExporter.download

    genDownload = ( name, str ) ->
        ->
            if $("body").hasClass("safari")
              blob = null
            else
              blob = new Blob [str]

            if not blob
              return {
                data : "data:text/plain;,#{str}"
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
            "click #property-user-data-detail" : "viewUserDataDetail"

        render : () ->
            data = @model.toJSON()
            data.windows = @model.get( 'osType' ) is 'windows'
            @$el.html template.main data

            if @resModel.isMesosSlave()
                @renderMesosData()

            @model.attributes.name

        renderMesosData: () ->
            slaveAttr = @resModel.getMesosAppAttributes( @model.get( 'instanceId' ) )
            @$( '#mesos-data-area' ).html template.mesosData slaveAttr

        keyPairClick: ( event ) ->
            @proccessKpStuff()

        proccessKpStuff: ( notOld ) ->
            if not notOld
                kp = @resModel.connectionTargets( "KeypairUsage" )[0]
                isOldDefaultKp = kp and kp.isDefault() and kp.get('appId') is "DefaultKP---#{Design.instance().get('id')}"
                isOldOtherKp = kp and not kp.isDefault()

                isOldKp = isOldDefaultKp or isOldOtherKp

                if isOldKp
                    @model.downloadKp kpName

            if not isOldKp and @model.get( 'osType' ) is 'windows'
                @decryptPassword()
            else
                @loginPrompt()



        loginPrompt: () ->
            keypair = @model.get 'keyName'

            new modalPlus {
                title: keypair,
                width: 420
                template: MC.template.modalDownloadKP {
                    loginCmd: @model.get "loginCmd"
                    windows: @model.get("osType") is "windows"
                }
                confirm: hide: true
            }
            me = this
            $( '#keypair-cmd' ).off( 'click' ).on 'click', ( event )->
                if event.currentTarget.select
                    event.currentTarget.select()
                event.stopPropagation()

            false

        decryptPassword : () ->
            #modal MC.template.modalDecryptPassword { name:@model.get('keyName'), isOldKp:false }
            me = @
            @kpModal = new modalPlus {
                title: lang.IDE.GET_WINDOWS_PASSWORD
                width: 500
                template: MC.template.modalDecryptPassword { name:@model.get('keyName'), isOldKp:false }
                disableFooter: true
            }
            @model.getPassword().then ( data )->
                me.updateKPModal("check", !!data)
            , ()->
                notification 'error', lang.NOTIFY.ERR_GET_PASSWD_FAILED

            $("#do-kp-decrypt").off( 'click' ).on 'click', ( event ) ->
                me.model.getPassword( me.__kpUpload.getData() ).then ( data )->
                    me.updateKPModal("got", data)
                , ()->
                    notification 'error', lang.NOTIFY.ERR_GET_PASSWD_FAILED
            false

        updateKPModal : ( action, data, data2, data3 ) ->
            if @kpModal.isClosed
                return

            if action is 'check'
                if data
                    @__kpUpload and @__kpUpload.remove()
                    @__kpUpload = new kp_upload({type: "Private Key"})
                    @__kpUpload.on 'load', () ->
                        $("#do-kp-decrypt").prop 'disabled', false

                    @kpModal.$( '.import-zone' ).html @__kpUpload.render().el
                    @kpModal.$( '.decrypt-action' ).show()
                else
                    @kpModal.$( '.import-zone' ).html ''
                    @kpModal.$( '.no-password' ).show()


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

            @sysLogModal = new modalPlus({
                template:MC.template.modalInstanceSysLog {log_content: ''}
                width: 900
                title: lang.IDE.SYSTEM_LOG + instanceId
                confirm: hide: true
            }).tpl.attr("id", "modal-instance-sys-log")

            that = this
            ApiRequest("ins_GetConsoleOutput",{
                key_id      : Design.instance().credentialId()
                region_name : Design.instance().region()
                instance_id : instanceId
            }).then ( data )->
                that.refreshSysLog( data.GetConsoleOutputResponse?.output )
                that.sysLogModal.resize()
            , ()->
                that.refreshSysLog(null, lang.IDE.SYSTEM_LOG_NOT_READY)
                that.sysLogModal.resize()
            return false

      viewUserDataDetail: ()->
            userData = @model.get("userData")
            self = @
            @userDataLog = new modalPlus({
              template: MC.template.modalInstanceSysLog {log_content: MC.template.convertBreaklines({content:userData})}
              width: 900
              title: lang.PROP.INSTANCE_USER_DATA
              confirm: hide: true
            }).tpl.attr("id", "modal-instance-sys-log")

            ApiRequest("ins_DescribeInstanceAttribute", {
              key_id: Design.instance().credentialId()
              region_name: Design.instance().region()
              instance_id: self.model.get("id")
              attribute_name: "userData"
            }).then (data)->
              console.log data
              userData = data?.DescribeInstanceAttributeResponse?.userData?.value
              self.refreshSysLog(userData)
              self.userDataLog.resize()
            , ()->
              self.refreshSysLog(null, lang.IDE.USER_DATA_FETCH_FAILED)
              self.userDataLog.resize()

        refreshSysLog : (result, errMessage) ->
          $('#modal-instance-sys-log .instance-sys-log-loading').hide()
          if errMessage
            $("#modal-instance-sys-log .instance-sys-log-info").text(errMessage).show()
          else
            logContent = Base64.decode(result)
            $contentElem = $('#modal-instance-sys-log .instance-sys-log-content')
            $contentElem.html MC.template.convertBreaklines({content:logContent})
            $contentElem.show()
    }

    new InstanceAppView()
