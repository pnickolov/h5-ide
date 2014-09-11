define [
    'constant'
    '../OsPropertyView'
    './template'

], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {
        render: ->
            poolName = @model.getTarget( constant.RESTYPE.OSPOOL ).get 'name'
            listenerName = @model.getTarget( constant.RESTYPE.OSLISTENER ).get 'name'

            @$el.html template { poolName: poolName, listenerName: listenerName }
            @

    }, {
        handleTypes: [ 'OsListenerAsso' ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }