define [ 'constant', 'CloudResources', 'toolbar_modal', './component/optiongroup/ogTpl', 'i18n!/nls/lang.js', 'event' ], ( constant, CloudResources, toolbar_modal, template, lang, ide_event ) ->

    Backbone.View.extend

        getModalOptions: ->
            title: "Edit Option Group"
            classList: 'option-group-manage'
            context: that

        initModal: () ->
            options =
                template        : ''
                title           : "Edit Option Group"
                disableFooter   : true
                disableClose    : true
                width           : '855px'
                height          : '473px'
                compact         : true

            @__modalplus = new modalplus options
            @__modalplus.on 'closed', @__close, @

        initialize: (engine, version) ->

            optionCol = CloudResources(constant.RESTYPE.DBENGINE, Design.instance().region())
            engineOptions = optionCol.getEngineOptions(engine)
            ogOptions = engineOptions[version] if engineOptions

            # option group data ready for engine and version
            if engineOptions
                null
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
            @renderList({})

        renderList: ( data ) ->
            @modal.setContent( template.modal_list data )

        renderNoCredential: () ->
            @modal.render('nocredential').toggleControls false

        renderSlides: ( which, checked ) ->
            tpl = template[ "slide_#{which}" ]
            slides = @getSlides()
            slides[ which ]?.call @, tpl, checked

        show: ->
            @processCol()
