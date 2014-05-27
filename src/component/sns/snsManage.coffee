define [ 'constant', 'CloudResources', 'toolbar_modal', './component/sns/snsTpl', 'i18n!nls/lang.js' ], ( constant, CloudResources, toolbar_modal, template, lang ) ->

    Backbone.View.extend

        tagName: 'section'

        initCol: ->
            region = Design.instance().region()
            @subCol = CloudResources constant.RESTYPE.SUBSCRIPTION, region
            @topicCol = CloudResources constant.RESTYPE.TOPIC, region
            @topicCol.on 'update', @processCol, @
            @subCol.on 'update', @processCol, @


        getModalOptions: ->
            that = @
            region = Design.instance().get('region')
            regionName = constant.REGION_SHORT_LABEL[ region ]

            title: "Manage SNS in #{regionName}"
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

        initialize: () ->
            @initCol()
            @initModal()

        doAction: ( action, checked ) ->
            @[action] and @[action](@validate(action), checked)

        validate: ( action ) ->
            switch action
                when 'create'
                    return not @M$( '#create-kp-name' ).parsley 'validate'
                when 'import'
                    return not @M$( '#import-kp-name' ).parsley 'validate'

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
        delete: ( invalid, checked ) ->
            count = checked.length

            onDeleteFinish = @genDeleteFinish count
            @switchAction 'processing'
            _.each checked, ( c ) ->
                m = @topicCol.get c.data.id
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
            @processCol()
            @

        processCol: () ->
            if @topicCol.isReady() and @subCol.isReady()

                data = @topicCol.map ( tModel ) ->
                    tData = tModel.toJSON()
                    sub = @subCol.where TopicArn: tData.id
                    tData.sub = sub.map ( sModel ) -> sModel.toJSON()
                    tData.subCount = tData.sub.length
                    tData

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
                # Setup the endpoint
                updateEndpoint = ( protocol ) ->
                    $input  = $(".property-asg-ep")#.removeClass("https http")
                    switch $modal.find(".selected").data("id")

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

                    endPoint = @M$ '#create-sns-endpoint'
                    endPoint.attr "placeholder", placeholder

                    endPoint.parsley 'custom', ( value ) ->
                        if type and value and ( not MC.validate type, value )
                            return errorMsg

                    if endPoint.val().length
                        endPoint.parsley 'validate'
                    null

                @M$( '.dd-protocol' ).on "OPTION_CHANGE", updateEndpoint

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




