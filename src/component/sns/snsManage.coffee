define [ 'constant', 'CloudResources', 'toolbar_modal', './component/sns/snsTpl', 'i18n!/nls/lang.js' ], ( constant, CloudResources, toolbar_modal, template, lang ) ->

    Backbone.View.extend

        tagName: 'section'

        initCol: ->
            region = Design.instance().region()
            @subCol = CloudResources constant.RESTYPE.SUBSCRIPTION, region
            @topicCol = CloudResources constant.RESTYPE.TOPIC, region
            @topicCol.on 'update', @processCol, @
            @subCol.on 'update', @processSubUpdate, @

        processSubUpdate: ->
            if not @M$( '.tr-detail' ).length
                @processCol()

        processSubCreate: ( newSub ) ->
            topicArn = newSub.get 'TopicArn'
            that = @
            @M$( '.detailed' ).each () ->
                if $(@).data( 'topicArn' ) is topicArn
                    that.detail null, $(@).data(), $(@)
                    return false

        quickCreate: ->
            @modal.triggerSlide 'create'

        getModalOptions: ->
            that = @
            region = Design.instance().get('region')
            regionName = constant.REGION_SHORT_LABEL[ region ]

            title: "Manage SNS in #{regionName}"
            classList: 'sns-manage'
            #slideable: _.bind that.denySlide, that
            context: that
            buttons: [
                {
                    icon: 'new-stack'
                    type: 'create'
                    name: 'Create Subscription'
                }
                {
                    icon: 'del'
                    type: 'delete'
                    disabled: true
                    name: 'Delete'
                }
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
                    name: 'Topic'
                }
                {
                    sortable: true
                    name: 'Topic ARN'
                }
                {
                    sortable: false
                    width: "20%" # or 40%
                    name: 'Subscription'
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
            @modal.on 'detail', @detail, @

        detail: ( event, data, $tr ) ->
            subModels =  @getSubs data.topicArn
            data = _.map subModels, ( m ) ->
                attrs = m.toJSON()
                attrs.isRemovable = m.isRemovable()
                attrs

            $trDetail = @modal.setDetail $tr, template.detail data
            @processDetail $trDetail, $tr

        processDetail: ( $trDetail, $tr ) ->
            that = @

            updateCount = ->
                subCount = $trDetail.find( '.sns-detail tbody tr' ).length
                # Update subscription count
                $tr.find( '.show-detail b' ).text( subCount )
                # fold the detail if there is no subscription
                if subCount is 0
                   $tr.find( '.show-detail' ).click()

            $trDetail
                .on( 'click', '.remove', () ->
                    $(@).hide()
                    $trDetail.find( '.do-remove-panel' ).show()
                )
                .on( 'click', '.cancel', () ->
                    $(@).closest( '.do-remove-panel' ).hide()
                    $trDetail.find( '.remove' ).show()
                )
                .on( 'click', '.do-remove', () ->
                    $removeBtn = $(@)
                    that.removeSub( $removeBtn.data('id') ).then () ->
                        $removeBtn.closest( 'tr' ).remove()
                        updateCount()

                )

            updateCount()

        removeSub: ( subId ) ->
            m = @subCol.findWhere SubscriptionArn: subId
            m?.destroy()
                .then( ( deletedModel )->
                    notification 'info', "Remove Subscription Succeed."
                    return deletedModel
                )
                .fail ( err ) ->
                    notification 'error', err.awsResult
                    throw err

        fetch: ->
            if App.user.hasCredential()
                @topicCol.fetch()
                @subCol.fetch()

        initialize: () ->
            @initCol()
            @initModal()
            @fetch()
            window.M$ = @M$

        doAction: ( action, checked ) ->
            @[action] and @[action](@validate(action), checked)

        validate: ( action ) ->
            switch action
                when 'create'
                    return not @M$( '#create-topic-name' ).parsley 'validateForm'

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

                if not error.length
                    that.modal.unCheckSelectAll()

                _.each error, ( s ) ->
                    console.log(s)

            ( res ) ->
                if res instanceof Backbone.Model
                    success.push res
                else
                    error.push res

                finHandler()

        errorHandler: ( awsError ) ->
            @modal.error awsError.awsResult

        # actions
        create: ( invalid ) ->
            if invalid then return false

            that = @
            @switchAction 'processing'
            topicId = @M$( '.dd-topic-name .selected' ).data 'id'
            protocol = @M$( '.dd-protocol .selected ' ).data 'id'
            topicName = @M$( '#create-topic-name' ).val()
            displayName = @M$( '#create-display-name' ).val()
            endpoint = @M$( '#create-endpoint' ).val()

            createSub = ( newTopic ) ->
                that.subCol.create( TopicArn: newTopic and newTopic.id or topicId, Endpoint: endpoint, Protocol: protocol )
                    .save()
                    .then ( newSub ) ->
                        that.processSubCreate newSub
                        notification 'info', 'Create Subscription Succeed'
                        that.modal.cancel()
                    .fail ( awsError ) ->
                        that.errorHandler awsError



            if topicId is '@new'
                @topicCol
                    .create( Name: topicName, DisplayName: displayName )
                    .save()
                    .then(createSub)
                    .fail ( awsError ) ->
                        that.errorHandler awsError

            else
                topicModel = @topicCol.get topicId
                if displayName is topicModel.get 'DisplayName'
                    createSub()
                else
                    topicModel.update( displayName ).then createSub


        delete: ( invalid, checked ) ->
            count = checked.length
            that = @

            onDeleteFinish = @genDeleteFinish count
            @switchAction 'processing'
            _.each checked, ( c ) ->
                m = that.topicCol.get c.data.id
                m?.destroy().then onDeleteFinish, onDeleteFinish

        refresh: ->
            @subCol.fetchForce()
            @topicCol.fetchForce()

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
            if App.user.hasCredential()
                @processCol()
            else
                @modal.render 'nocredential'
            @

        processCol: ( noRender ) ->
            that = @
            if @topicCol.isReady() and @subCol.isReady()
                data = @topicCol.map ( tModel ) ->
                    tData = tModel.toJSON()
                    sub = that.subCol.where TopicArn: tData.id
                    tData.sub = sub.map ( sModel ) -> sModel.toJSON()
                    tData.subCount = tData.sub.length
                    tData

                if not noRender
                    @renderList data

            data

        getSubs: ( topicArn ) ->
            @subCol.where TopicArn: topicArn

        renderList: ( data ) ->
            @modal.setContent( template.modal_list data )

        renderNoCredential: () ->
            @modal.render('nocredential').toggleControls false

        renderSlides: ( which, checked ) ->
            tpl = template[ "slide_#{which}" ]
            slides = @getSlides()
            slides[ which ]?.call @, tpl, checked

        getSlides: ->
            that = @
            modal = @modal

            create: ( tpl, checked ) ->
                modal.setSlide tpl @processCol true

                updateEndpoint = ( protocol ) ->
                    selectedProto = that.M$('.dd-protocol .selected').data 'id'
                    switch selectedProto
                        when "sqs"
                            placeholder = lang.ide.PROP_STACK_AMAZON_ARN
                            type        = lang.ide.PROP_STACK_SQS
                            errorMsg    = lang.ide.PARSLEY_PLEASE_PROVIDE_A_VALID_AMAZON_SQS_ARN

                        when "arn"
                            placeholder = lang.ide.PROP_STACK_AMAZON_ARN
                            type        = lang.ide.PROP_STACK_ARN
                            errorMsg    = lang.ide.PARSLEY_PLEASE_PROVIDE_A_VALID_APPLICATION_ARN

                        when "email"
                            placeholder = lang.ide.PROP_STACK_EXAMPLE_EMAIL
                            type        = lang.ide.PROP_STACK_EMAIL
                            errorMsg    = lang.ide.HEAD_MSG_ERR_UPDATE_EMAIL3

                        when "email-json"
                            placeholder = lang.ide.PROP_STACK_EXAMPLE_EMAIL
                            type        = lang.ide.PROP_STACK_EMAIL
                            errorMsg    = lang.ide.HEAD_MSG_ERR_UPDATE_EMAIL3

                        when "sms"
                            placeholder = lang.ide.PROP_STACK_E_G_1_206_555_6423
                            type        = lang.ide.PROP_STACK_USPHONE
                            errorMsg    = lang.ide.PARSLEY_PLEASE_PROVIDE_A_VALID_PHONE_NUMBER

                        when "http"
                            #$input.addClass "http"
                            placeholder = lang.ide.PROP_STACK_HTTP_WWW_EXAMPLE_COM
                            type        = lang.ide.PROP_STACK_HTTP
                            errorMsg    = lang.ide.PARSLEY_PLEASE_PROVIDE_A_VALID_URL

                        when "https"
                            #$input.addClass "https"
                            placeholder = lang.ide.PROP_STACK_HTTPS_WWW_EXAMPLE_COM
                            type        = lang.ide.PROP_STACK_HTTPS
                            errorMsg    = lang.ide.PARSLEY_PLEASE_PROVIDE_A_VALID_URL

                    endPoint = that.M$ '#create-endpoint'
                    endPoint.attr "placeholder", placeholder

                    endPoint.parsley 'custom', ( value ) ->
                        if type and value and ( not MC.validate type, value )
                            return errorMsg

                    null

                updateEndpoint 'email'

                that.M$( '#create-display-name' ).parsley 'custom', ( value ) ->
                    selectedProto = that.M$('.dd-protocol .selected').data 'id'
                    if selectedProto is 'sms' and not value
                        return 'Display Name is required if subscription uses SMS protocol.'
                    null

                that.M$( '#create-topic-name' ).parsley 'custom', ( value ) ->
                    if that.topicCol.where( Name: value ).length
                        return 'Topic name is already taken.'
                    null



                $allTextBox = that.M$( '.slide-create input[type=text]' )

                validateRequired = ->
                    pass = true

                    $allTextBox.each ->
                        if $(@).is(':hidden') then return
                        if @id is 'create-display-name'
                            selectedProto = that.M$('.dd-protocol .selected').data 'id'
                            if selectedProto is 'sms'
                                pass = false if not @value.trim().length
                        else
                            pass = false if not @value.trim().length
                    pass

                processCreateBtn = ( event, showError ) ->
                    $target = event and $( event.currentTarget ) or $( '#create-topic-name' )

                    if validateRequired()
                        that.M$( '.slide-create .do-action' ).prop 'disabled', false
                    else
                        that.M$( '.slide-create .do-action' ).prop 'disabled', true

                $allTextBox.on 'keyup', processCreateBtn

                that.M$( '.dd-protocol' ).off( 'OPTION_CHANGE' ).on 'OPTION_CHANGE', ( id ) ->
                    updateEndpoint id
                    processCreateBtn null, true

                that.M$( '.dd-topic-name' ).off( 'OPTION_CHANGE' ).on 'OPTION_CHANGE', ( event, id, data ) ->
                    if id is '@new'
                        that.M$( '.create-sns-topic' ).show()
                    else
                        that.M$( '#create-display-name').val data.displayName
                        that.M$( '.create-sns-topic' ).hide()



            "delete": ( tpl, checked ) ->
                checkedAmount = checked.length

                if not checkedAmount
                    return

                data = {}

                if checkedAmount is 1
                    data.selecteKeyName = checked[ 0 ].data.name
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


        filter: ( keyword ) ->
            @processCol( true, keyword )




