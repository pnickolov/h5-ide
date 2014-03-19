#############################
#  View Mode for design/property/cgw
#############################

define [ '../base/model', 'constant', "../base/main" ], ( PropertyModel, constant, PropertyModule ) ->

  StaticSubModel = PropertyModel.extend {

    init : ( uid ) ->

      @set "isApp", @isApp

      # If this uid is ami uid
      ami = MC.data.dict_ami[ uid ]
      if ami
        @set ami
        @set "instance_type", MC.aws.ami.getInstanceType( ami ).join(", ")
        @set "ami", true
        @set "name", ami.name
        return
      else if uid.indexOf("ami-") is 0
        @set "ami", { unavailable : true }
        @set "name", uid
        return

      @set "name", uid
      # If this uid is snapshot uid
      snapshot_list = MC.data.config[Design.instance().region()].snapshot_list
      if snapshot_list and snapshot_list.item
        for item in snapshot_list.item
          if item.snapshotId is uid
            @set item
            return

      false

    canChangeAmi : ( amiId )->
      component = Design.instance().component( PropertyModule.activeModule().uid )
      oldAmi = component.getAmi() || component.get("cachedAmi")
      newAmi = MC.data.dict_ami[ amiId ]
      if not oldAmi and not newAmi then return "Ami info is missing, please reopen stack and try again."

      if oldAmi.osType is "windows" and newAmi.osType isnt "windows"
        return "Changing AMI platform is not supported. To use a #{newAmi.osFamily} AMI, please create a new instance instead."

      if oldAmi.osType isnt "windows" and newAmi.osType is "windows"
        return "Changing AMI platform is not supported. To use a #{newAmi.osFamily} AMI, please create a new instance instead."

      if (newAmi.instance_type or newAmi.instanceType or "").indexOf( component.get("instanceType") ) is -1
        return "#{newAmi.name} does not support previously used instance type #{component.get("instanceType")}. Please change another AMI."

      true

    getAmiPngName : ( amiId ) ->
      ami = MC.data.dict_ami[ amiId ]
      if not ami
        "ami-not-available"
      else
        "#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}"

    getAmiName : ( amiId )->
      ami = MC.data.dict_ami[ amiId ]
      if not ami
        ""
      else
        ami.name

    changeAmi : ( amiId )->
      Design.instance().component( PropertyModule.activeModule().uid ).setAmi( amiId )
      @init( amiId )
      null

    getInstanceName : ()->
      Design.instance().component( PropertyModule.activeModule().uid ).get("name")
  }

  new StaticSubModel()
