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
        handleTypes: [ 'globalconfig' ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }