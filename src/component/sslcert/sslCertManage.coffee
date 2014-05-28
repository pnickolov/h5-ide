define [ 'constant', 'CloudResources', 'toolbar_modal', './component/sslcert/sslCertTpl', 'i18n!nls/lang.js' ], ( constant, CloudResources, toolbar_modal, template, lang ) ->

    Backbone.View.extend

        tagName: 'section'

        initCol: ->
            @sslCertCol = CloudResources constant.RESTYPE.IAM
            @sslCertCol.on 'update', @processCol, @

        getModalOptions: ->
            that = @
            region = Design.instance().get('region')
            regionName = constant.REGION_SHORT_LABEL[ region ]

            title: "Manage SSL Certificate"
            classList: 'sslcert-manage'
            #slideable: _.bind that.denySlide, that
            context: that
            buttons: [
                {
                    icon: 'new-stack'
                    type: 'create'
                    name: 'Upload New SSL Certificate'
                },
                {
                    icon: 'edit'
                    type: 'update'
                    disabled: true
                    name: 'Update'
                },
                {
                    icon: 'del'
                    type: 'delete'
                    disabled: true
                    name: 'Delete'
                },
                {
                    icon: 'refresh'
                    type: 'refresh'
                    name: ''
                }
            ]
            columns: [
                {
                    sortable: true
                    width: "25%" # or 40%
                    name: 'Name'
                }
                {
                    sortable: true
                    name: 'Upload Date'
                }
            ]

        initModal: () ->
            new toolbar_modal @getModalOptions()
            @modal.on 'close', () ->
                @remove()
            , @

            @modal.on 'slidedown', @renderSlides, @
            @modal.on 'action', @doAction, @
            @modal.on 'refresh', @refresh, @

        initialize: () ->
            @initCol()
            @initModal()

        doAction: ( action, checked ) ->
            @[action] and @[action](@validate(action), checked)

        validate: ( action ) ->
            switch action
                when 'create'
                    true

        genDeleteFinish: ( times ) ->
            success = []
            error = []
            that = @

            finHandler = _.after times, ->
                that.modal.cancel()
                if success.length is 1
                    notification 'info', "#{success[0].get 'Name'} is deleted."
                else if success.length > 1
                    notification 'info', "Selected #{success.length} SNS topic are deleted."

                if not that.model.get( 'keys' ).length
                    that.M$( '#kp-select-all' )
                        .get( 0 )
                        .checked = false

                _.each error, ( s ) ->
                    console.log(s)

            ( res ) ->
                if res instanceof Backbone.Model
                    success.push res
                else
                    error.push res

                finHandler()

        # actions
        create: ( invalid ) ->

            that = @
            @switchAction 'processing'

            $certName = $('#ssl-cert-name-input')
            $certPrikey = $('#ssl-cert-privatekey-input')
            $certPubkey = $('#ssl-cert-publickey-input')
            $certChain = $('#ssl-cert-chain-input')

            @sslCertCol.create(
                Name: $certName.val(),
                CertificateBody: $certPubkey.val(),
                PrivateKey: $certPrikey.val(),
                CertificateChain: $certChain.val(),
                Path: ''
            ).save().then (result) ->
                notification 'info', 'Create SSL Certificate Succeed'
                that.modal.cancel()
            , (result) ->
                that.switchAction()
                if result.awsresult
                    notification 'error', result.awsresult

        delete: ( invalid, checked ) ->
            count = checked.length

            onDeleteFinish = @genDeleteFinish count
            @switchAction 'processing'
            _.each checked, ( c ) ->
                m = @sslCertCol.get c.data.id
                m?.destroy().then onDeleteFinish, onDeleteFinish

        refresh: ->
            @sslCertCol.fetchForce()

        switchAction: ( state ) ->
            if not state
                state = 'init'

            @M$( '.slidebox .action' ).each () ->
                if $(@).hasClass state
                    $(@).show()
                else
                    $(@).hide()

        render: ->
            @modal.render()
            @processCol()
            @

        processCol: () ->
            if @sslCertCol.isReady()

                data = @sslCertCol.map ( sslCertModel ) ->
                    sslCertData = sslCertModel.toJSON()
                    sslCertData.UploadDate = MC.dateFormat(new Date(sslCertData.UploadDate), 'yyyy-MM-dd hh:mm:ss')
                    sslCertData

                @renderList data

            false

        renderList: ( data ) ->
            @modal.setContent( template.modal_list data )

        renderNoCredential: () ->
            @modal.render('nocredential').toggleControls false

        renderSlides: ( which, checked ) ->
            tpl = template[ "slide_#{which}" ]
            slides = @getSlides()
            slides[ which ]?.call @, tpl, checked

        processSlideCreate: ->


        getSlides: ->
            that = @
            modal = @modal

            create: ( tpl, checked ) ->
                
                modal.setSlide tpl

                allTextBox = that.M$( '.slide-create input, .slide-create textarea' )

                processCreateBtn = ( event ) ->
                    if $(event.currentTarget).parsley 'validateForm', false
                        that.M$( '.slide-create .do-action' ).prop 'disabled', false
                    else
                        that.M$( '.slide-create .do-action' ).prop 'disabled', true

                allTextBox.on 'keyup', processCreateBtn

            "delete": ( tpl, checked ) ->
                checkedAmount = checked.length

                if not checkedAmount
                    return

                data = {}

                if checkedAmount is 1
                    data.selecteKeyName = checked[ 0 ].data[ 'name' ]
                else
                    data.selectedCount = checkedAmount

                modal.setSlide tpl data

            import: ( tpl, checked ) ->
                modal.setSlide tpl
                that.__upload and that.__upload.remove()
                that.__upload = new upload()
                that.__upload.on 'load', that.afterImport, @
                that.M$( '.import-zone' ).html that.__upload.render().el


        show: ->
            if App.user.hasCredential()
                @topicCol.fetch()
                @subCol.fetch()
                @processCol()
            else
                @renderNoCredential()

        manage: ->

        set: ->

        filter: ( keyword ) ->
            @processCol( true, keyword )
