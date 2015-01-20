define [ '../template/TplCredential', 'backbone' ], ( TplCredential ) ->
    Backbone.View.extend
        events:
            '': ''

        className: 'credential'

        render: () ->
            @$el.html TplCredential.credentialManagement
            @