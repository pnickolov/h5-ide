define [
  'constant'
  '../OsPropertyView'

], ( constant, OsPropertyView ) ->

    OsPropertyView.extend {
        render: ->
            @$el.html '123'
            @

    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
        handleModes: [ 'stack', 'appedit' ]
    }