define [
  'constant'
  './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {
        limits:
            'abc': /123/
    }, {
        handleTypes: [ constant.RESTYPE.OSPOOL ]
    }