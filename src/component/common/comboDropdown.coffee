# Combo Dropdown
# Return Backbone.View object

# Usage:
# 1. import this component
# 2. new comboDropdown()
# 3. bind `open`, `manage`, `change`, `filter` event
# 4. fill the content and selection

### Example:
define [ 'combo_dropdown' ], ( combo_dropdown ) ->
    dropdown = new combo_dropdown()
    @dropdown = dropdown

    @dropdown.on 'open', @open, @
    @dropdown.on 'manage', @manageKp, @
    @dropdown.on 'change', @setKey, @
    @dropdown.on 'filter', @filter, @

    render: () ->
        @dropdown.setSelection '$defaultKp'

    open = () ->
        @dropdown.setContent template
###

define [ './component/common/comboDropdownTpl', 'backbone', 'jquery' ], ( template, Backbone, $ ) ->


    Backbone.View.extend

        tagName: 'section'

        events:
            'click .combo-dd-manage'    : 'manage'
            'click .show-credential'    : 'showCredential'

            'OPTION_SHOW .selectbox'    : 'optionShow'
            'OPTION_CHANGE .selectbox'  : 'optionChange'

            'keyup .combo-dd-filter'    : 'filter'
            'keydown .combo-dd-filter'  : 'stopPropagation'
            'click .combo-dd-filter'    : 'returnFalse'


        stopPropagation: ( event ) ->
            event.stopPropagation()

        returnFalse: ->
            false

        showCredential: ->
            App.showSettings App.showSettings.TAB.Credential

        filter: ( event ) ->
            @trigger 'filter', event.currentTarget.value

        manage: ( event ) ->
            @trigger 'manage'
            event.stopPropagation()

        optionShow: ->
            @trigger 'open'

        optionChange: ( event, name, data ) ->
            @trigger 'change', name, data

        initialize: ( options ) ->
            @$el.html template.frame options
            @

        render: ( tpl ) ->
            @$( '.combo-dd-content' ).html template[ tpl ] or tpl
            @

        setSelection: ( dom ) ->
            @$( '.selection' ).html dom
            @

        setContent: ( dom ) ->
            @$( '.combo-dd-content' ).html template.listframe
            @$( '.combo-dd-list' ).html dom
            @

        # whichOne shoud be `filter` or `manage`
        toggleControls: ( showOrHide, whichOne ) ->
            if whichOne
                @$( ".combo-dd-#{whichOne}" ).toggle showOrHide
            else
                @$( '.combo-dd-filter, .combo-dd-manage' ).toggle showOrHide
            @

        delegate: ( event, selector, handler ) ->
            @$el.on.apply arguments
            @




