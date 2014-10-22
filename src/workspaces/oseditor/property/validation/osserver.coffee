define [
  'constant'
  './ValidationBase'
  './osport'
], ( constant, ValidationBase, PortValidation ) ->

  ValidationBase.extend {

    limits:

      fixedIp: ValidationBase.limit.ipv4

    fixedIp: (new PortValidation()).ip

  }, {
    handleTypes: [ constant.RESTYPE.OSSERVER ]
  }
