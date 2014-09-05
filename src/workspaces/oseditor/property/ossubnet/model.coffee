define [
  'constant'
  '../OsPropertyModel'

], ( constant, OsPropertyModel ) ->

    OsPropertyModel.extend {

    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
        handleModes: [ 'stack', 'appedit' ]
    }