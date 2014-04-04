#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view', './template/app' ], ( PropertyView, template ) ->

    LCAppView = PropertyView.extend {

        events:
            'click #property-app-keypair'                   : 'downloadKeypair'
            'change #property-instance-enable-cloudwatch'   : 'cloudwatchSelect'
            'change #property-instance-user-data'           : 'userdataChange'

        kpModalClosed: false

        render: () ->
            data = @model.toJSON()
            @$el.html template data
            data.name

        cloudwatchSelect : ( event ) ->
            @model.setCloudWatch event.target.checked
            $("#property-cloudwatch-warn").toggle( $("#property-instance-enable-cloudwatch").is(":checked") )

        userdataChange : ( event ) ->
            @model.setUserData event.target.value

        downloadKeypair: ( event ) ->
            keypair = $( event.currentTarget ).html()
            @model.downloadKP( keypair )

            modal MC.template.modalDownloadKP { name  : keypair }

            me = this
            $('#modal-wrap').on "closed", () ->
                me.kpModalClosed = true
                null

            this.kpModalClosed = false

            false

        updateKPModal: ( data ) ->
            if not data
                modal.close()
                return

            if this.kpModalClosed
                return

            $("#keypair-login").hide()
            $("#keypair-remote").hide()
            $("#keypair-public").hide()
            $("#keypair-rdp").hide()

            $("#keypair-kp-linux" )
                .attr("href", "data://text/plain;charset=utf8," + encodeURIComponent data )
                .attr("download", $("#keypair-name").text() + ".pem" )

            $("#keypair-private-key").val( data )

            $("#keypair-loading").hide()
            $("#keypair-body-linux" ).show()

    }

    new LCAppView()
