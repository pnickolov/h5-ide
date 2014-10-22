define [
  'constant'
  './ValidationBase'
  './osport'
], ( constant, ValidationBase, portValidation ) ->

  ValidationBase.extend {

    limits:

      fixedIp: ValidationBase.limit.ipv4

    fixedIp: (new portValidation()).ip

  }, {
    handleTypes: [ constant.RESTYPE.OSSERVER ]
  }
