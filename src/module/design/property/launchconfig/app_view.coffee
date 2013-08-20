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

        render     : () ->
            console.log 'property:instance app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes

        downloadKeypair : ( event ) ->
            keypair = $( event.currentTarget ).html()
            this.trigger "REQUEST_KEYPAIR", keypair

            modal MC.template.modalDownloadKP { keypairname : keypair }
            false

        updateKPModal : ( data ) ->
            if not data
                modal.close()
                return

            $saveBtn = $("#property-app-save-kp")
            $model   = $saveBtn.closest "#modal-box"
            $model.find(".modal-body").html("Keypair data is ready. Please click save button.")
            $saveBtn.removeClass("btn-gray").addClass("btn-blue")
                    .attr("href", "data://text/plain;charset=utf8," + encodeURIComponent(data) )
                    .attr("download", $("#property-keypair-name").html() + ".pem" )

    }

    view = new LCAppView()

    return view
