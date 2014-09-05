define [
  'constant'
  '../OsPropertyView'
  './stack'
], ( constant, OsPropertyView, stackTpl ) ->

    OsPropertyView.extend {
        render: ->
            @$el.html stackTpl({})

    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
        handleModes: [ 'stack', 'appedit' ]
    }