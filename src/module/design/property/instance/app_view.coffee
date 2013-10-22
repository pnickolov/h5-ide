#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view', 'text!./template/app.html', 'i18n!nls/lang.js', 'UI.zeroclipboard' ], ( PropertyView, template, lang, zeroclipboard )->

    template = Handlebars.compile template

    InstanceAppView = PropertyView.extend {

        events   :
            "click #property-app-keypair" : "downloadKeypair"
            "click #property-app-ami" : "openAmiPanel"

        kpModalClosed : false

        render : () ->
            @$el.html template @model.attributes
            @model.attributes.name

        downloadKeypair : ( event ) ->
            keypair = $( event.currentTarget ).html()
            this.trigger "REQUEST_KEYPAIR", keypair

            modal MC.template.modalDownloadKP { name  : keypair }

            me = this
            $('#modal-wrap').on "closed", ()->
                me.kpModalClosed = true
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
                copybtn = $("#keypair-pwd").val( option.passwd ).siblings("a").attr("data-clipboard-text", option.passwd )
                zeroclipboard.copy copybtn
            else
                $("#keypair-login").hide()
                $("#keypair-no-pwd").text lang.ide.POP_DOWNLOAD_KP_NOT_AVAILABLE

            if option.cmd_line
                copybtn = $("#keypair-cmd").val( option.cmd_line ).siblings("a").attr("data-clipboard-text", option.cmd_line )
                zeroclipboard.copy copybtn
            else
                $("#keypair-remote").hide()

            if option.public_dns
                copybtn = $("#keypair-dns").val( option.public_dns ).siblings("a").attr("data-clipboard-text", option.public_dns )
                zeroclipboard.copy copybtn
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

        openAmiPanel : ( event ) ->
            this.trigger "OPEN_AMI", $( event.target ).data("uid")
            false

    }

    new InstanceAppView()
