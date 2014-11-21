define [
    'constant'
    '../OsPropertyView'
    './template'

], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {
        render: ->
            namePort1 = @model.getTarget( constant.RESTYPE.OSPOOL ).get 'name'
            namePort2 = @model.getTarget( constant.RESTYPE.OSLISTENER ).get 'name'

            @$el.html template { namePort1: namePort1, namePort2: namePort2 }
            @

    }, {
        handleTypes: [ 'OsListenerAsso' ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }