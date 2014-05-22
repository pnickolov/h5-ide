# Combo Dropdown
# Return Backbone.View object

# Usage:
# 1. import this component
# 2. new toolbarModal()
# 3. bind `open`, `manage`, `change`, `filter` event
# 4. fill the content and selection

### Example:

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

            # do action
            'click .do-action': 'doAction'
            'click .cancel': 'cancel'
            'click [data-btn=delete]': 'refresh'

        initialize: ( options ) ->
            @options = options

        handleSlide: ( event ) ->
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

        delegate: ( event, selector, handler ) ->
            @$el.on.apply arguments
            @




