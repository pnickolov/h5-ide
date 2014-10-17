define [
  'constant'
  './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {

    }, {
        handleTypes: [ constant.RESTYPE.OSPOOL ]
    }