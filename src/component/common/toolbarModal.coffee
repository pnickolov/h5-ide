# Combo Dropdown
# Return Backbone.View object

# Usage:
# 1. import this component
# 2. new toolbar_modal()
# 3. bind `slideup`, `slidedown`, `refresh` event
# 4. fill the content and selection

### Example:
define [ 'toolbar_modal' ], ( toolbar_modal ) ->
    modalOptions :
        title: "Manage Key Pairs in #{{regionName}}"
        buttons: [
            {
                icon: 'new-stack'
                type: 'create'
                name: 'Create Key Pair'
            }
            {
                icon: 'del'
                type: 'delete'
                disalbed: true
                name: 'Delete'
            }
        ]
        columns: [
            {
                sortable: true
                width: 100px # or 40%
                name: 'Name'
            }
            {
                sortable: false
                width: 100px # or 40%
                name: 'Fingerprint'
            }
        ]

    bindModal: () ->
        @modal = new toolbar_modal @modalOptions

        @modal.on 'slideup', @donothing, @
        @modal.on 'slidedown', @slideDown, @
        @modal.on 'refresh', @setKey, @

    initialize: () ->
        @bindModal()
        events =
            'click .xxx', @youkown


    render: () ->


        @modal.render(options)

    open = () ->
        @modal.setContent template


###

define [ './component/common/toolbarModalTpl', 'backbone', 'jquery', 'UI.modalplus', 'UI.notification' ], ( template, Backbone, $, modalplus ) ->


    Backbone.View.extend

        tagName: 'section'

        __slide: null

        __modalplus: null

        events:
            'click .modal-close' : 'close'
            'change #t-m-select-all': 'checkAll'
            'change .one-cb': 'checkOne'

            # actions
            'click .t-m-btn': 'handleSlide'
            'click .cancel': 'cancel'

            # do action
            'click .do-action': 'doAction'
            'click .cancel': 'cancel'
            'click [data-btn=refresh]': 'refresh'

        initialize: ( options ) ->
            @options = options or {}
            @options.title = 'Default Title' if not @options.title
            if options.context
                @options.context.modal = @
                @options.context.m$ = _.bind @$, @

        doAction: ( event ) ->
            @error()
            action = $( event.currentTarget ).data 'action'
            @trigger 'action', action, @__getChecked()


        __getChecked: () ->
            allChecked = @$('.one-cb:checked')
            checkedInfo = []
            allChecked.each () ->
                checkedInfo.push id: @id, value: @value, data: $(@).data()

            checkedInfo

        __slideRejct: ->
            _.isFunction( @options.slideable ) and not @options.slideable()


        handleSlide: ( event ) ->
            if @__slideRejct()
                return @

            $button = $ event.currentTarget
            $slidebox = @$( '.slidebox' )
            button = $button.data 'btn'
            $activeButton = @$( '.toolbar .active' )
            activeButton = $activeButton and $activeButton.data 'btn'


            # has active button
            if $activeButton
                # slide up
                if $activeButton.get( 0 ) is $button.get( 0 )
                    @trigger 'slideup', button
                    $button.removeClass 'active'
                    $slidebox.removeClass 'show'
                    @__slide = null
                #slide down
                else
                    @trigger 'slidedown', button, @__getChecked()
                    $activeButton.removeClass 'active'
                    $button.addClass 'active'
                    $slidebox.addClass 'show'
                    @__slide = button

            else
                @trigger 'slidedown', button, @__getChecked()
                $button.addClass 'active'
                $slidebox.addClass 'show'
                @__slide = button


        refresh: ->
            if @__slideRejct()
                return @
            @renderLoading()
            @trigger 'refresh'

        close: ( event ) ->
            $( '#modal-wrap' ).off 'click', @stopPropagation
            modal.close()
            @trigger 'close'
            @remove()
            false

        checkOne: ( event ) ->
            $target = $ event.currentTarget
            @processDelBtn()
            cbAll = @$ '#t-m-select-all'
            cbAmount = @$('.one-cb').length
            checkedAmount = @$('.one-cb:checked').length
            $target.closest('tr').toggleClass 'selected'

            if checkedAmount is cbAmount
                cbAll.prop 'checked', true
            else if cbAmount - checkedAmount is 1
                cbAll.prop 'checked', false

        checkAll: ( event ) ->
            @processDelBtn()
            if event.currentTarget.checked
                @$('input[type="checkbox"]').prop 'checked', true
                @$('tr.item').addClass 'selected'
            else
                @$('input[type="checkbox"]').prop 'checked', false
                @$('tr.item').removeClass 'selected'

        processDelBtn: () ->
            that = @
            _.defer () ->
                if that.$('.one-cb:checked').length
                    that.$('[data-btn=delete]').prop 'disabled', false
                else
                    that.$('[data-btn=delete]').prop 'disabled', true

        stopPropagation: ( event ) ->
            exception = '.sortable, #download-kp'
            if not $(event.target).is( exception )
                event.stopPropagation()

        open: () ->
            options =
                template        : @el
                title           : @options.title
                disableFooter   : true
                disableClose    : true
                width           : '855px'
                height          : '473px'
                compact         : true



            @__modalplus = new modalplus options
            $( '#modal-wrap' ).click @stopPropagation

        renderLoading: () ->
            @$( '.content-wrap' ).html template.loading
            @

        __toggleLoading: ( showOrHide ) ->
            @$( '.loading-spinner' ).toggle not showOrHide
            @$( '.content-wrap' ).toggle showOrHide


        # ------ In Common Use ------ #

        render: ( refresh ) ->
            data = @options

            data.buttons = _.reject data.buttons, ( btn ) ->
                if btn.type is 'create'
                    data.btnValueCreate = btn.name
                    true
            @__toggleLoading false
            @$el.html template.frame data
            if not refresh
                @open()
            @

        setContent: ( dom ) ->
            if not @$( '.scroll-content' ).length
                @render true

            @$( '.t-m-content' ).html dom
            @__toggleLoading true
            @

        setSlide: ( dom ) ->
            @$( '.slidebox .content' ).html dom
            @error()
            @

        cancel: () ->
            if @__slideRejct()
                return @

            $slidebox = @$( '.slidebox' )
            $activeButton = @$( '.toolbar .active' )

            @trigger 'slideup', $activeButton.data 'btn'
            $activeButton.removeClass 'active'
            $slidebox.removeClass 'show'
            @

        delegate: ( events, context ) ->
            if not events or not _.isObject(events) then return @

            for key, method in events
                if not method then continue

                match = key.match /^(\S+)\s*(.*)$/
                eventName = match[1]
                selector = match[2]
                method = _.bind method, context or this
                eventName += '.delegateEvents' + @cid
                if selector is ''
                  @$el.on eventName, method
                else
                  @$el.on eventName, selector, method

            @

        error: (msg) ->
            $error = @$( '.error' )
            if msg
                $error.text( msg ).show()
            else
                $error.hide()


        getSlide: ->
            @__slide



