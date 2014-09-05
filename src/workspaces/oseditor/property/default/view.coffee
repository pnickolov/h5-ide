define [
  'constant'
  '../OsPropertyView'
  './template'

], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {
        render: ->
            @$el.html template {}
            @

    }, {
        handleTypes: [ 'default' ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }