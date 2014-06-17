#############################
#  View Mode for design/property/cgw
#############################

define [ '../base/model', 'constant', "../base/main", "CloudResources", "Design" ], ( PropertyModel, constant, PropertyModule, CloudResources, Design ) ->

  StaticSubModel = PropertyModel.extend {

    init : ( uid ) ->

      @set "isApp", @isApp

      InstanceModel = Design.modelClassForType( constant.RESTYPE.INSTANCE )

      # If this uid is ami uid
      ami = CloudResources( constant.RESTYPE.AMI, Design.instance().region() ).get( uid )
      if ami
        ami = ami.toJSON()
        @set ami
        @set "instance_type", (InstanceModel.getInstanceType( ami, Design.instance().region() ) || []).join(", ")
        @set "ami", true
        @set "name", ami.name
        return
      else if uid.indexOf("ami-") is 0
        @set "ami", { unavailable : true }
        @set "name", uid
        return

      @set "name", uid
      # If this uid is snapshot uid
      item = CloudResources( constant.RESTYPE.SNAP, Design.instance().region() ).get( uid )
      if not item then return false
      @set item.attributes
      true

    canChangeAmi : ( amiId )->
      component = Design.instance().component( PropertyModule.activeModule().uid )
      oldAmi = component.getAmi() || component.get("cachedAmi")
      newAmi = CloudResources( constant.RESTYPE.AMI, Design.instance().region() ).get( amiId )
      if newAmi then newAmi = newAmi.toJSON()

      if not oldAmi and not newAmi then return "Ami info is missing, please reopen stack and try again."

      if oldAmi.osType is "windows" and newAmi.osType isnt "windows"
        return "Changing AMI platform is not supported. To use a #{newAmi.osFamily} AMI, please create a new instance instead."

      if oldAmi.osType isnt "windows" and newAmi.osType is "windows"
        return "Changing AMI platform is not supported. To use a #{newAmi.osFamily} AMI, please create a new instance instead."

      instanceType = Design.modelClassForType( constant.RESTYPE.INSTANCE ).getInstanceType( newAmi, Design.instance().region() )

      if instanceType.indexOf( component.get("instanceType") ) is -1
        return "#{newAmi.name} does not support previously used instance type #{component.get("instanceType")}. Please change another AMI."

      true

    getAmiPngName : ( amiId ) ->
      ami = CloudResources( constant.RESTYPE.AMI, Design.instance().region() ).get( amiId )
      if not ami
        "ami-not-available"
      else
        ami = ami.attributes
        "#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}"

    getAmiName : ( amiId )->
      ami = CloudResources( constant.RESTYPE.AMI, Design.instance().region() ).get( amiId )
      if ami then ami.get("name") else ""

    changeAmi : ( amiId )->
      Design.instance().component( PropertyModule.activeModule().uid ).setAmi( amiId )
      @init( amiId )
      null

    getInstanceName : ()->
      Design.instance().component( PropertyModule.activeModule().uid ).get("name")
  }

  new StaticSubModel()
