define [ "Design", "constant" ], ( Design, constant ) ->

  OsDesign = Design.extend {
    instancesNoUserData : ()->
      result = true
      instanceModels = Design.modelClassForType(constant.RESTYPE.OSSERVER).allObjects()
      _.each instanceModels , (serverModel)->
        result = if  serverModel.get('userData') then false else true
        null
      return result
  }

  OsDesign
