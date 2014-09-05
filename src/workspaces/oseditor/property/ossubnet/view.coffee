define [
  'constant'
  '../OsPropertyView'

], ( constant, OsPropertyView ) ->

    OsPropertyView.extend {

    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
        handleModes: [ 'stack', 'appedit' ]
    }