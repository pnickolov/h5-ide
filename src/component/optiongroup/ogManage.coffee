define [ 'constant', 'CloudResources', 'toolbar_modal', './component/optiongroup/ogTpl', 'i18n!/nls/lang.js', 'event' ], ( constant, CloudResources, toolbar_modal, template, lang, ide_event ) ->

    Backbone.View.extend

        tagName: 'section'

        initCol: ->

            # @sslCertCol = CloudResources constant.RESTYPE.IAM
            # if App.user.hasCredential()
            #     @sslCertCol.fetch()
            # @sslCertCol.on 'update', @processCol, @
            # @sslCertCol.on 'change', @processCol, @
            @processCol()

        getModalOptions: ->

            that = @
            region = Design.instance().get('region')
            regionName = constant.REGION_SHORT_LABEL[ region ]

            title: "Edit Option Group"
            classList: 'option-group-manage'
            #slideable: _.bind that.denySlide, that
            context: that

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

            @initModal()
            @initCol()

        quickCreate: ->
            @modal.triggerSlide 'create'

        doAction: ( action, checked ) ->
            @[action] and @[action](@validate(action), checked)

        validate: ( action ) ->
            switch action
                when 'create'
                    true

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

        processCol: () ->

            # if @sslCertCol.isReady()

            #     data = @sslCertCol.map ( sslCertModel ) ->
            #         sslCertData = sslCertModel.toJSON()
            #         sslCertData.UploadDate = MC.dateFormat(new Date(sslCertData.UploadDate), 'yyyy-MM-dd hh:mm:ss')
            #         sslCertData

            #     @renderList data

            # false

            @renderList({})

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
                # @sslCertCol.fetch()
                @processCol()
            else
                @renderNoCredential()

        manage: ->

        set: ->

        filter: ( keyword ) ->
            @processCol( true, keyword )
