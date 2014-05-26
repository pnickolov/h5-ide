# Combo Dropdown
# Return Backbone.View object

# Usage:
# 1. import this component
# 2. new toolbar_modal()
# 3. bind `slideup`, `slidedown`, `refresh` event
# 4. fill the content and selection

### Example:
Refer to kpView.coffee


###

define [ './component/common/toolbarModalTpl', 'backbone', 'jquery', 'UI.modalplus', 'UI.notification' ], ( template, Backbone, $, modalplus ) ->


    Backbone.View.extend

        tagName: 'section'

        __slide: null

        __modalplus: null

        events:
            'change #t-m-select-all': '__checkAll'
            'change .one-cb': '__checkOne'

            'click .t-m-btn': '__handleSlide'
            'click .cancel': 'cancel'

            'click .do-action': '__doAction'
            'click [data-btn=refresh]': '__refresh'

        initialize: ( options ) ->
            @options = options or {}
            @options.title = 'Default Title' if not @options.title
            if options.context
                @options.context.modal = @
                @options.context.m$ = _.bind @$, @

        __doAction: ( event ) ->
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


        __handleSlide: ( event ) ->
            if @__slideRejct()
                return @

            $button = $ event.currentTarget
            $slidebox = @$( '.slidebox' )
            button = $button.data 'btn'
            $activeButton = @$( '.toolbar .active' )
            activeButton = $activeButton and $activeButton.data 'btn'


            # has active button
            if $activeButton.length
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


        __refresh: ->
            if @__slideRejct()
                return @
            @__renderLoading()
            @trigger 'refresh'

        __close: ( event ) ->
            $( '#modal-wrap' ).off 'click', @__stopPropagation
            @trigger 'close'
            @remove()
            false

        __checkOne: ( event ) ->
            $target = $ event.currentTarget
            @__processDelBtn()
            cbAll = @$ '#t-m-select-all'
            cbAmount = @$('.one-cb').length
            checkedAmount = @$('.one-cb:checked').length
            $target.closest('tr').toggleClass 'selected'

            if checkedAmount is cbAmount
                cbAll.prop 'checked', true
            else if cbAmount - checkedAmount is 1
                cbAll.prop 'checked', false

        __checkAll: ( event ) ->
            @__processDelBtn()
            if event.currentTarget.checked
                @$('input[type="checkbox"]').prop 'checked', true
                @$('tr.item').addClass 'selected'
            else
                @$('input[type="checkbox"]').prop 'checked', false
                @$('tr.item').removeClass 'selected'

        __processDelBtn: () ->
            that = @
            _.defer () ->
                if that.$('.one-cb:checked').length
                    that.$('[data-btn=delete]').prop 'disabled', false
                else
                    that.$('[data-btn=delete]').prop 'disabled', true

        __stopPropagation: ( event ) ->
            exception = '.sortable, #download-kp'
            if not $(event.target).is( exception )
                event.stopPropagation()

        __open: () ->
            options =
                template        : @el
                title           : @options.title
                disableFooter   : true
                disableClose    : true
                width           : '855px'
                height          : '473px'
                compact         : true



            @__modalplus = new modalplus options
            @__modalplus.on 'closed', @__close, @
            $( '#modal-wrap' ).click @__stopPropagation

        __renderLoading: () ->
            @$( '.content-wrap' ).html template.loading
            @

        __toggleLoading: ( showOrHide ) ->
            @$( '.loading-spinner' ).toggle not showOrHide
            @$( '.content-wrap' ).toggle showOrHide


        # ------ INTERFACE ------ #

        render: ( refresh ) ->
            data = @options

            data.buttons = _.reject data.buttons, ( btn ) ->
                if btn.type is 'create'
                    data.btnValueCreate = btn.name
                    true
            @__toggleLoading false
            @$el.html template.frame data
            if not refresh
                @__open()
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



