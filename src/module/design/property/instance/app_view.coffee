#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ 'event', 'MC',
         'i18n!nls/lang.js',
         'UI.zeroclipboard',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC, lang, zeroclipboard ) ->

    InstanceAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'
        ip_list_template : Handlebars.compile $( '#property-ip-list-tmpl' ).html()

        events   :
            "click #property-app-keypair" : "downloadKeypair"
            "click #property-app-ami" : "openAmiPanel"

        template  : Handlebars.compile $( '#property-instance-app-tmpl' ).html()

        kpModalClosed : false

        render     : () ->
            console.log 'property:instance app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes

            this.refreshIPList()


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

        refreshIPList : ( event ) ->
            this.model.getEni()
            $( '#property-network-list' ).html(this.ip_list_template(this.model.attributes))
            this.changeIPAddBtnState()

        changeIPAddBtnState : () ->

            disabledBtn = false
            instanceUID = this.model.get 'get_uid'

            maxIPNum = MC.aws.eni.getENIMaxIPNum(instanceUID)
            currentENIComp = MC.aws.eni.getInstanceDefaultENI(instanceUID)
            if !currentENIComp
                disabledBtn = true
                return

            currentIPNum = currentENIComp.resource.PrivateIpAddressSet.length
            if maxIPNum is currentIPNum
                disabledBtn = true

            instanceType = MC.canvas_data.component[instanceUID].resource.InstanceType
            if disabledBtn
                tooltipStr = sprintf(lang.ide.PROP_MSG_WARN_ENI_IP_EXTEND, instanceType, maxIPNum)
                $('#instance-ip-add').addClass('disabled').attr('data-tooltip', tooltipStr).data('tooltip', tooltipStr)
            else
                $('#instance-ip-add').removeClass('disabled').attr('data-tooltip', 'Add IP Address').data('tooltip', 'Add IP Address')

            null


    }

    view = new InstanceAppView()

    return view
