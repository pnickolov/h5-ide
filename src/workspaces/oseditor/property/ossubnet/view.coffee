define [
  'constant'
  '../OsPropertyView'

], ( constant, OsPropertyView ) ->

    OsPropertyView.extend {
        render: ->


    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
        handleModes: [ 'stack', 'appedit' ]
    }