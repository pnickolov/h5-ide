define [
  'constant'
  '../OsPropertyView'
  './stack'

], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {
        events:
            'change #property-os-listener-name': 'updateAttribute'
            'change #property-os-listener-limit': 'updateAttribute'
            'change #property-os-listener-protocol': 'updateAttribute'
            'change #property-os-listener-port': 'updateAttribute'

        render: ->
            @$el.html template @model.toJSON()
            @



    }, {
        handleTypes: [ constant.RESTYPE.OSLISTENER ]
        handleModes: [ 'stack', 'appedit' ]
    }