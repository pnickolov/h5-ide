define [ './template', 'backbone', 'jquery'], ( template, Backbone, $ ) ->
    Backbone.View.extend

        tagName: 'section'
        id: 'keypair-select'
        className: 'selectbox'

        events:
            'click .state-status-item-detail': 'openStateEditor'

        initialize: ( options ) ->

        render: () ->
            @renderFrame()
            @

        renderFrame: () ->
            @$el.html template.frame






