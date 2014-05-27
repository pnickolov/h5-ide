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
                    width: "100px" # or 40%
                    name: 'Topic'
                }
                {
                    sortable: true
                    width: "100px" # or 40%
                    name: 'Topic ARN'
                }
                {
                    sortable: false
                    width: "100px" # or 40%
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
                    return not @m$( '#create-kp-name' ).parsley 'validate'
                when 'import'
                    return not @m$( '#import-kp-name' ).parsley 'validate'

        refresh: ->
            @subCol.fetchForce()
            @topicCol.fetchForce()

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
            tpl = template_modal[ "slide_#{which}" ]
            slides = @getSlides()
            slides[ which ]?.call @, tpl, checked


        getSlides: ->
            that = @
            modal = @modal
            __upload = @__upload


            create: ( tpl, checked ) ->
                modal.setSlide tpl

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
                that.m$( '.import-zone' ).html that.__upload.render().el


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




