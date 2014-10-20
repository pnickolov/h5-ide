
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["OpsModel", "ApiRequest", "constant", "CloudResources" ], ( OpsModel, ApiRequest, constant, CloudResources )->

  AwsOpsModel = OpsModel.extend {
    type : "OpenstackOps"

    initialize : ( attr, options )->
      OpsModel.prototype.initialize.call this, attr, options

      @attributes.cloudType = "openstack"
      if not @get("provider")
        @attributes.provider = if options.jsonData.provider then options.jsonData.provider else "awcloud"
      return

    getMsrId : ()->
      msrId = OpsModel.prototype.getMsrId.call this
      if msrId then return msrId
      if not @__jsonData then return undefined
      for uid, comp of @__jsonData.component
        if comp.type is constant.RESTYPE.OSNETWORK
          return comp.resource.id
      undefined

    __initJsonData : ()->
      json = @__createRawJson()

      layout =
        "NETWORK" :
          coordinate : [ 34, 3 ]
          size       : [ 60, 60 ]

      component =
        # DefaultKP Component
        'KP' :
          type     : "OS::Nova::KeyPair"
          name     : "DefaultKP"
          resource : {}

        "NETWORK":
          type: "OS::Neutron::Network"
          resource:
            name : "network1"

        "SG":
          type: "OS::Neutron::SecurityGroup"
          resource:
            name: "DefaultSG"
            description: "default security group"
            rules: []

      for id, comp of component
        comp.uid = MC.guid()
        json.component[ comp.uid ] = comp

        if layout[ id ]
          l = layout[id]
          l.uid = comp.uid
          json.layout[ l.uid ] = l

      @__jsonData = json
      return
  }

  AwsOpsModel
