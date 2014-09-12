define [
  'constant'
  '../OsPropertyView'
  './stack'

], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {
        events:
            'change [data-target]': 'updateAttribute'

        render: ->
            @$el.html template @model.toJSON()
            @



    }, {
        handleTypes: [ constant.RESTYPE.OSLISTENER ]
        handleModes: [ 'stack', 'appedit' ]
    }