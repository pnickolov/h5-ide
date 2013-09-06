#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ 'event', 'MC',
         'UI.zeroclipboard',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC, zeroclipboard ) ->

    InstanceAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        events   :
            "click #property-app-keypair" : "downloadKeypair"
            "click #property-app-ami" : "openAmiPanel"

        template  : Handlebars.compile $( '#property-instance-app-tmpl' ).html()

        kpModalClosed : false

        render     : () ->
            console.log 'property:instance app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes


        downloadKeypair : ( event ) ->
            keypair = $( event.currentTarget ).html()
            this.trigger "REQUEST_KEYPAIR", keypair

            modal MC.template.modalDownloadKP { name  : keypair }

            me = this
            $('#modal-wrap').on "closed", ()->
                me.kpModalClosed = true
                null

            kpModalClosed = false

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

            if option.cmd_line
                copybtn = $("#keypair-cmd").val( option.cmd_line ).siblings("a").attr("data-clipboard-text", option.cmd_line )
                zeroclipboard.copy copybtn
            else
                $("#keypair-remote").hide()

            if option.dns
                copybtn = $("#keypair-dns").val( option.dns ).siblings("a").attr("data-clipboard-text", option.dns )
                zeroclipboard.copy copybtn

            if option.rdp
                $("#keypair-rdp")
                    .attr("href", "data://text/plain;charset=utf8," + encodeURIComponent( option.rdp ) )
                    .attr("download", $("#keypair-name").text() + ".rdp" )
            else
                $("#keypair-rdp").hide()


            $("#keypair-kp")
                .attr("href", "data://text/plain;charset=utf8," + encodeURIComponent(data) )
                .attr("download", $("#keypair-name").text() + ".pem" )

            $("#keypair-private-key").val( data )

            $("#keypair-loading").hide()
            $("#keypair-body-" + option.type ).show()

        openAmiPanel : ( event ) ->
            this.trigger "OPEN_AMI", $( event.target ).data("uid")
            false

    }

    view = new InstanceAppView()

    return view
