define [
  'constant'
  './ValidationBase'
  './osport'
  'CloudResources'
  'i18n!/nls/lang.js'
], ( constant, ValidationBase, PortValidation, CloudResources, lang) ->

  ValidationBase.extend {

    limits:

      fixedIp: ValidationBase.limit.ipv4
      volumeSize: ValidationBase.limit.positive

    fixedIp: (new PortValidation()).ip

    volumeSize: (value)->
      value = parseInt(value)
      imageId = @model.get("imageId")
      image = CloudResources(constant.RESTYPE.OSIMAGE, Design.instance().region()).get(imageId)
      minSize = parseInt(image.get("vol_size"))
      if value < minSize
        return lang.IDE.VALIDATION_VOLUME_SIZE_LARGE_THAN_IMAGE_SIZE

  }, {
    handleTypes: [ constant.RESTYPE.OSSERVER ]
  }
