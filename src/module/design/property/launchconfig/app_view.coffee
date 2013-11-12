#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view', 'text!./template/app.html' ], ( PropertyView, template ) ->

    template = Handlebars.compile template

    LCAppView = PropertyView.extend {

        events   :
            "click #property-app-keypair" : "downloadKeypair"

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

            this.kpModalClosed = false

            false

        updateKPModal : ( data ) ->
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
                .attr("href", "data://text/plain;charset=utf8," + encodeURIComponent(data) )
                .attr("download", $("#keypair-name").text() + ".pem" )

            $("#keypair-private-key").val( data )

            $("#keypair-loading").hide()
            $("#keypair-body-linux" ).show()

    }

    new LCAppView()
