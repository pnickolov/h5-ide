define [
    'constant'
    '../OsPropertyView'
    './stack'
    './app'

], ( constant, OsPropertyView, TplStack, TplApp ) ->

    OsPropertyView.extend {
        events:
            'change [data-target]': 'updateAttribute'

        render: ->
            template = switch
                when @mode is 'app' then TplApp
                else TplStack

            @$el.html template @model.toJSON()
            @

    }, {
        handleTypes: [ 'globalconfig' ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }