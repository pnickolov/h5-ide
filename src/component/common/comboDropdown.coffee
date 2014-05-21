define [ './component/common/comboDropdownTpl', 'backbone', 'jquery' ], ( template, Backbone, $ ) ->


Backbone.View.extend

    tagName: 'section'

    events:
        'click .combo-dd-manage'    : 'manage'
        'click .show-credential'    : 'showCredential'

        'OPTION_SHOW .selectbox'    : 'optionShow'
        'OPTION_CHANGE .selectbox'  : 'optionChange'

        'keyup .combo-dd-filter'    : 'filter'
        'keydown .combo-dd-filter'  : 'preventDefault'
        'click .combo-dd-filter'    : 'returnFalse'


    preventDefault: ( event ) ->
        event.preventDefault()

    returnFalse: ->
        false

    filter: ( event ) ->
        @trigger 'filter', event.currentTarget.value

    manage: ->
        @trigger 'manage'

    optionShow: ->
        @trigger 'open'

    optionChange: ( event, name, data ) ->
        @trigger 'change', name, data

    initialize: ( options ) ->
        @$el.html template.frame
        @

    render: ( tpl ) ->
        @$( '.combo-dd-content' ).html template[ tpl ] or tpl
        @

    setSelection: ( dom ) ->
        @$( '.selection' ).html dom

    setContent: ( dom ) ->
        @$( '.combo-dd-content' ).html template.listframe
        @$( '.combo-dd-list' ).html dom




