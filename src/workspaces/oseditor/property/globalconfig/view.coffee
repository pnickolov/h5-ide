define [
    'constant'
    '../OsPropertyView'
    './template'

], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {
        events:
            'change [data-target]': 'updateAttribute'

        initialize: ->
            @model = Design.instance()

        render: ->
            @$el.html template @model.toJSON()
            @

    }, {
        handleTypes: [ 'globalconfig' ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }