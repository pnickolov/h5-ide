# Combo Dropdown
# Return Backbone.View object

# Usage:
# 1. import this component
# 2. new comboDropdown()
# 3. bind `open`, `manage`, `change`, `filter` event
# 4. fill the content and selection

### Example:
Refer to kpView.coffee

###

define [ 'component/common/comboDropdownTpl', 'backbone', 'jquery' ], ( template, Backbone, $ ) ->


    Backbone.View.extend

        tagName: 'section'

        events:
            'click .combo-dd-manage'    : '__manage'
            'click .show-credential'    : '__showCredential'

            'OPTION_SHOW .selectbox'    : '__optionShow'
            'OPTION_CHANGE .selectbox'  : '__optionChange'

            'keyup .combo-dd-filter'    : '__filter'
            'keydown .combo-dd-filter'  : '__stopPropagation'
            'click .combo-dd-filter'    : '__returnFalse'
            'click .create-one'         : '__quickCreate'


        __quickCreate: () ->
            @trigger 'quick_create'

        __stopPropagation: ( event ) ->
            event.stopPropagation()

        __returnFalse: ->
            false

        __showCredential: ->
            App.showSettings App.showSettings.TAB.Credential

        __filter: ( event ) ->
            @trigger 'filter', event.currentTarget.value

        __manage: ( event ) ->
            @trigger 'manage'
            event.stopPropagation()

        __optionShow: ->
            # Close Parameter Group Dropdown
            $('#property-dbinstance-parameter-group-select .selectbox').removeClass 'open'
            if not @$('.combo-dd-content').html().trim()
                @render 'loading'

            @trigger 'open'

        __optionChange: ( event, name, data ) ->
            @trigger 'change', name, data

        initialize: ( options ) ->
            @$el.html template.frame options
            @


        # ------ INTERFACE ------ #

        render: ( tpl ) ->
            @$( '.combo-dd-content' ).html template[ tpl ] and template[ tpl ]() or tpl
            @

        setSelection: ( dom ) ->
            @$( '.selection' ).html dom
            @

        getSelection: ( dom ) ->
            $.trim(@$( '.selection' ).text())

        setContent: ( dom ) ->
            @$( '.combo-dd-content' ).html template.listframe
            @$( '.combo-dd-list' ).html dom
            @

        # Parameter whichOne shoud be `filter` or `manage`
        toggleControls: ( showOrHide, whichOne ) ->
            if whichOne
                @$( ".combo-dd-#{whichOne}" ).toggle showOrHide
            else
                @$( '.combo-dd-filter, .combo-dd-manage' ).toggle showOrHide
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




