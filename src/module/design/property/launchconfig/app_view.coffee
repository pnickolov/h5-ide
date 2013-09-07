#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    LCAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        events   :
            "click #property-app-keypair" : "downloadKeypair"

        template  : Handlebars.compile $( '#property-launchconfig-app-tmpl' ).html()

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

    view = new LCAppView()

    return view
