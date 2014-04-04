#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view', './template/app', 'i18n!nls/lang.js', 'instance_model' ], ( PropertyView, template, lang, instance_model )->

    InstanceAppView = PropertyView.extend {
        events   :
            "click #property-app-keypair" : "downloadKeypair"
            "click #property-app-ami" : "openAmiPanel"
            "click .property-btn-get-system-log" : "openSysLogModal"

        kpModalClosed : false

        render : () ->
            @$el.html template @model.attributes
            @model.attributes.name

        downloadKeypair : ( event ) ->
            keypair = $( event.currentTarget ).html()
            @model.downloadKP(keypair)

            modal MC.template.modalDownloadKP { name  : keypair }

            me = this
            $('#modal-wrap').on "closed", ()->
                me.kpModalClosed = true
                null

            $(".modal-body").on "click", ".click-select", ( event )->
                if event.currentTarget.select
                    event.currentTarget.select()
                event.stopPropagation()


            $("#keypair-show").on "click", ()->
                $("#keypair-pwd").attr("type", "string")
                null


            this.kpModalClosed = false

            false

        updateKPModal : ( data, option ) ->
            if not data
                modal.close()
                return

            if this.kpModalClosed
                return

            if option.passwd
                $("#keypair-pwd").val( option.passwd )
            else
                $("#keypair-login").hide()
                $("#keypair-no-pwd").text lang.ide.POP_DOWNLOAD_KP_NOT_AVAILABLE

            if option.cmd_line
                $("#keypair-cmd").val( option.cmd_line )
            else
                $("#keypair-remote").hide()

            if option.public_dns
                $("#keypair-dns").val( option.public_dns )
            else
                $("#keypair-public").hide()

            if option.rdp
                $("#keypair-rdp")
                    .attr("href", "data://text/plain;charset=utf8," + encodeURIComponent( option.rdp ) )
                    .attr("download", $("#keypair-name").text() + ".rdp" )
            else
                $("#keypair-rdp").hide()


            $("#keypair-kp-" + option.type )
                .attr("href", "data://text/plain;charset=utf8," + encodeURIComponent(data) )
                .attr("download", $("#keypair-name").text() + ".pem" )

            $("#keypair-private-key").val( data )

            $("#keypair-loading").hide()
            $("#keypair-body-" + option.type ).show()

            modal.position()
            null

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
