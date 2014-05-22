# Combo Dropdown
# Return Backbone.View object

# Usage:
# 1. import this component
# 2. new toolbar_modal()
# 3. bind `slideup`, `slidedown`, `refresh` event
# 4. fill the content and selection

### Example:
define [ 'toolbar_modal' ], ( toolbar_modal ) ->

    bindModal: () ->
        @modal = new toolbar_modal()

        @modal.on 'slideup', @donothing, @
        @modal.on 'slidedown', @slideDown, @
        @modal.on 'refresh', @setKey, @

    initialize: () ->
        @bindModal()
        events =
            'click .xxx', @youkown


    render: () ->
        options =
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

        @modal.render(options)

    open = () ->
        @modal.setContent template


###

define [ './component/common/toolbarModalTpl', 'backbone', 'jquery' ], ( template, Backbone, $ ) ->


    Backbone.View.extend

        tagName: 'section'

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
            'click [data-btn=delete]': 'refresh'

        initialize: ( options ) ->
            @options = options

        cancel: () ->
            if _.isFunction( @options.validate ) and not @options.validate()
                return @

            $slidebox = @$( '.slidebox' )
            $activeButton = @$( '.toolbar .active' )

            @trigger 'slideup', $activeButton.data 'btn'
            $activeButton.removeClass 'active'
            $slidebox.removeClass 'show'
            @

        handleSlide: ( event ) ->
            if _.isFunction( @options.validate ) and not @options.validate()
                return @

            $button = $ event.currentTarget
            $slidebox = @$( '.slidebox' )
            button = $target.data 'btn'
            $activeButton = @$( '.toolbar .active' )
            activeButton = $activeButton and $activeButton.data 'btn'


            if $activeButton
                # slide up
                if $activeButton is $button
                    @trigger 'slideup', button
                    $button.removeClass 'active'
                    $slidebox.removeClass 'show'
                #slide down
                else
                    @trigger 'slidedown', button
                    $activeButton.removeClass 'active'
                    $button.addClass 'active'

            else
                @trigger 'slidedown', button
                $button.addClass 'active'
                $slidebox.addClass 'show'


        refresh: ->
            @renderLoading()
            @trigger 'refresh'

        renderLoading: () ->
            @$( '.content-wrap' ).html template.loading
            @

        close: ( event ) ->
            $( '#modal-wrap' ).off 'click', @stopPropagation
            modal.close()
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
                if that.$('input:checked').length
                    that.$('[data-btn=delete]').prop 'disabled', false
                else
                    that.$('[data-btn=delete]').prop 'disabled', true

        stopPropagation: ( event ) ->
            exception = '.sortable, #download-kp'
            if not $(event.target).is( exception )
                event.stopPropagation()

        open: () ->
            modal @el
            $( '#modal-wrap' ).click @stopPropagation



        # ------ In Common Use ------ #

        render: ( refresh ) ->
            data = @options
            @$el.html template.frame data
            if not refresh
                @open()
            @

        setContent: ( dom ) ->
            if not @$( '.scroll-content' ).length
                @render true

            @$( '.t-m-content' ).html dom
            @

        setSlide: ( dom ) ->
            @$( '.slidebox .content' ).html dom
            @error()
            @

        delegate: ( events ) ->
            if not events or not _.isObject(events) then return @

            for key, method in events
                if not method then continue

                match = key.match /^(\S+)\s*(.*)$/
                eventName = match[1]
                selector = match[2]
                method = _.bind(method, this);
                eventName += '.delegateEvents' + @cid;
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



