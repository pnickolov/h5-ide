define [
  'constant'
  './ValidationBase'
], ( constant, ValidationBase ) ->

  ValidationBase.extend {

    limits:

      fixedIp: ValidationBase.limit.ipv4

    fixedIp: (value) ->
      return 'pool have some port valid error.'

  }, {
    handleTypes: [ constant.RESTYPE.OSSERVER ]
  }
