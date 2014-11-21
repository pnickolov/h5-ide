define [
  'constant'
  '../OsPropertyView'
  './template'

], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {
        render: ->
            @$el.html template @getRenderData()
            @

    }, {
        handleTypes: [ constant.RESTYPE.OSNETWORK ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }