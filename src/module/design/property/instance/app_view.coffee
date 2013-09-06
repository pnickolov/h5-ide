#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    InstanceAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        events   :
            "click #property-app-keypair" : "downloadKeypair"
            "click #property-app-ami"     : "openAmiPanel"

        template  : Handlebars.compile $( '#property-instance-app-tmpl' ).html()

        render     : () ->
            console.log 'property:instance app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes

        downloadKeypair : ( event ) ->
            keypair = $( event.currentTarget ).html()
            this.trigger "REQUEST_KEYPAIR", keypair

            modal MC.template.modalDownloadKP {
                keypairname : keypair
            }
            false

        updateKPModal : ( data, win_passwd ) ->
            if not data
                modal.close()
                return

            $saveBtn = $("#property-app-save-kp")
            $model   = $saveBtn.closest "#modal-box"
            $model.find(".modal-body").html("Key pair data is ready. Click save button to download.")

            if win_passwd
                $model.find(".model-login-info").html(win_passwd)

            $saveBtn.removeClass("disabled").addClass("btn-blue")
                    .attr("href", "data://text/plain;charset=utf8," + encodeURIComponent(data) )
                    .attr("download", $("#property-keypair-name").html() + ".pem" )

        openAmiPanel : ( event ) ->
            this.trigger "OPEN_AMI", $( event.target ).data("uid")
            false

    }

    view = new InstanceAppView()

    return view
