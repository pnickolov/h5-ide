
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
        @attributes.provider = if options.jsonData.provider then options.jsonData.provider else App.user.get("default_provider")
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
          coordinate : [ 27, 3 ]
          size       : [ 60, 60 ]
        "SUBNET" :
          coordinate : [ 30, 6 ]
          size       : [ 25, 54 ]
        "RT" :
          coordinate : [ 10, 3 ]

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

        "RT":
          type : "OS::Neutron::Router"
          resource :
            external_gateway_info : {}

        "SUBNET" : {
            type : "OS::Neutron::Subnet"
            resource :
              cidr        : "10.0.0.0/16"
              enable_dhcp : true
        }

      for id, comp of component
        comp.uid = MC.guid()
        json.component[ comp.uid ] = comp

        if layout[ id ]
          l = layout[id]
          l.uid = comp.uid
          json.layout[ l.uid ] = l

        if comp.type is "OS::Neutron::Subnet"
          subnetId = comp.uid
        else if comp.type is "OS::Neutron::Network"
          networkId = comp.uid

      for id, comp of component
        if comp.type is "OS::Neutron::Subnet"
          comp.resource.network_id = "@{#{networkId}.resource.id}"
        else if comp.type is "OS::Neutron::Router"
          comp.resource.router_interface = [{ subnet_id : "@{#{subnetId}.resource.id}"}]

      @__jsonData = json
      return
  }

  AwsOpsModel
