define [ 'constant', 'CloudResources', 'toolbar_modal', './component/sslcert/sslCertTpl', 'i18n!nls/lang.js', 'event' ], ( constant, CloudResources, toolbar_modal, template, lang, ide_event ) ->

    Backbone.View.extend

        tagName: 'section'

        initCol: ->
            @sslCertCol = CloudResources constant.RESTYPE.IAM
            @sslCertCol.fetch()
            @sslCertCol.on 'update', @processCol, @
            @sslCertCol.on 'change', @processCol, @

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
                    width: "50%"
                    name: 'Name'
                }
                {
                    sortable: true
                    width: "33%"
                    name: 'Upload Date'
                }
                {
                    sortable: false
                    name: 'View Details'
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
            @modal.on 'checked', @checked, @
            @modal.on 'detail', @detail, @

        initialize: () ->
            @initCol()
            @initModal()

        quickCreate: ->
            @modal.triggerSlide 'create'

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

            certName = $certName.val()
            @sslCertCol.create(
                Name: certName,
                CertificateBody: $certPubkey.val(),
                PrivateKey: $certPrikey.val(),
                CertificateChain: $certChain.val(),
                Path: ''
            ).save().then (result) ->
                notification 'info', "Certificate #{certName} is uploaded"
                that.modal.cancel()
            , (result) ->
                that.switchAction()
                if result.awsResult
                    notification 'error', result.awsResult

        delete: ( invalid, checked ) ->
            count = checked.length

            onDeleteFinish = @genDeleteFinish count
            @switchAction 'processing'
            _.each checked, ( c ) ->
                m = @sslCertCol.get c.data.id
                m?.destroy().then onDeleteFinish, onDeleteFinish

        update: ( invalid, checked ) ->

            that = @
            @switchAction 'processing'

            if checked and checked[0]

                sslCertId = checked[0].data.id
                sslCertData = that.sslCertCol.get(sslCertId)
                oldCerName = sslCertData.get('Name')
                newCertName = $('#ssl-cert-name-update-input').val()

                if newCertName is oldCerName
                    
                    that.modal.cancel()

                else

                    sslCertData.update(
                        Name: newCertName
                    ).then (result) ->
                        certName = newCertName
                        notification 'info', "Certificate #{certName} is updated"

                        # refresh ssl cert related
                        sslCertModelAry = Design.modelClassForType(constant.RESTYPE.IAM).allObjects()
                        _.each sslCertModelAry, (sslCertModel) ->
                            if sslCertModel.get('name') is oldCerName
                                sslCertModel.set('name', newCertName)
                                sslCertModel.set('arn', sslCertData.get('Arn'))
                            null
                        # $selectCertItem = $('.sslcert-placeholder .selection').filter () ->
                        #     return $(this).text() == oldCerName
                        # $selectCertItem.text(newCertName)
                        ide_event.trigger ide_event.REFRESH_PROPERTY

                        that.modal.cancel()
                    , (result) ->
                        that.switchAction()
                        if result.awsResult
                            notification 'error', result.awsResult

        detail: (event, data, $tr) ->

            that = this
            sslCertId = data.id
            sslCertData = sslCertCol.get(sslCertId).toJSON()
            sslCertData.Expiration = MC.dateFormat(new Date(sslCertData.Expiration), 'yyyy-MM-dd hh:mm:ss')
            
            detailTpl = template['detail_info']
            @modal.setDetail($tr, detailTpl(sslCertData))

        refresh: ->
            @sslCertCol.fetchForce()

        checked: ( event, checkedAry ) ->
            $editBtn = @M$('.toolbar .icon-edit')
            if checkedAry.length is 1
                $editBtn.removeAttr('disabled')
            else
                $editBtn.attr('disabled', 'disabled')

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

            delete: ( tpl, checked ) ->

                checkedAmount = checked.length

                if not checkedAmount
                    return

                data = {}

                if checkedAmount is 1
                    data.selecteKeyName = checked[ 0 ].data[ 'name' ]
                else
                    data.selectedCount = checkedAmount

                modal.setSlide tpl data

            update: ( tpl, checked ) ->

                that = this

                if checked and checked[0]

                    certName = checked[0].data.name
                    modal.setSlide tpl({
                        cert_name: certName
                    })

                allTextBox = that.M$( '.slide-update input' )

                processCreateBtn = ( event ) ->
                    if $(event.currentTarget).parsley 'validateForm', false
                        that.M$( '.slide-update .do-action' ).prop 'disabled', false
                    else
                        that.M$( '.slide-update .do-action' ).prop 'disabled', true

                allTextBox.on 'keyup', processCreateBtn

        show: ->
            if App.user.hasCredential()
                @processCol()
            else
                @renderNoCredential()

        manage: ->

        set: ->

        filter: ( keyword ) ->
            @processCol( true, keyword )
