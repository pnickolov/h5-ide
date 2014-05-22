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
            'click .t-m-btn': 'renderSlide'

            # do action
            'click .do-action': 'doAction'
            'click .cancel': 'cancel'

        initialize: ( options ) ->



        close: ( event ) ->
            if @needDownload()
                return false
            $( '#modal-wrap' ).off 'click', @stopPropagation
            modal.close()
            @remove()
            false

        checkOne: ( event ) ->
            $target = $ event.currentTarget
            @processDelBtn()
            cbAll = @$ '#kp-select-all'
            cbAmount = @model.get( 'keys' ).length
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

        stopPropagation: ( event ) ->
            event.stopPropagation()



        delegate: ( event, selector, handler ) ->
            @$el.on.apply arguments
            @




