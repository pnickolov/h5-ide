define [ '../template/TplBasicSettings', 'backbone' ], ( TplBasicSettings ) ->
    Backbone.View.extend
        events:
            '': ''

        className: 'basic-settings'

        render: () ->
            @$el.html TplBasicSettings
            @