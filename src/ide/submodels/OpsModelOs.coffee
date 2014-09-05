
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["OpsModel", "ApiRequest", "constant", "CloudResources" ], ( OpsModel, ApiRequest, constant, CloudResources )->

  AwsOpsModel = OpsModel.extend {
    type : "OpenstackOps"

    # This method init a json for a newly created stack.
    __createRawJson : ()->
      json = OpsModel.prototype.__createRawJson.call this
      json.cloud_type = "openstack"
      json.provider   = "awcloud"
      json

    __initJsonData : ()->
      json = @__createRawJson()
      json.layout    =
        size : [ 240, 240 ]
        "ExternalNetwork" :
          coordinate : [ 5, 5 ]
        "router0001" :
          coordinate : [ 20, 5 ]
        "network0001" :
          coordinate : [ 34, 3 ]
          size       : [ 60, 60 ]
        "subnet0001" :
          coordinate : [ 36, 6 ]
          size       : [ 20, 50 ]
        "subnet0002" :
          coordinate : [ 60, 6 ]
          size       : [ 20, 50 ]
        "server0001" :
          coordinate : [ 42, 10 ]
        "port0002" :
          coordinate : [ 42, 20 ]
        "pool0001" :
          coordinate : [ 42, 40 ]
        "listener0001" :
          coordinate : [ 65, 40 ]

      json.component =
        "server0001" :
          type : "OS::Nova::Server"
          uid  : "server0001"
          resource :
            name   : "Server01"
            NICS : [{"port-id" : "@{port0001.resource.id}"}, {"port-id" : "@{port0002.resource.id}"}]
        "port0001" :
          type : "OS::Neutron::Port"
          uid  : "port0001"
          resource :
            name : "Port01"
            fixed_ips: [{
              "subnet_id"  : "@{subnet0001.resource.id}"
              "ip_address" : "10.0.0.12"
            }]
            security_groups : [ "@{sg0001.resource.id}"]
            network_id      : "@{network0001.resource.id}"
        "port0002" :
          type : "OS::Neutron::Port"
          uid  : "port0002"
          resource :
            name : "Port02"
            fixed_ips: [{
              "subnet_id"  : "@{subnet0001.resource.id}"
              "ip_address" : "10.0.0.13"
            }]
            security_groups : [ "@{sg0001.resource.id}"]
            network_id      : "@{network0001.resource.id}"
        "network0001" :
          type : "OS::Neutron::Network"
          uid  : "network0001"
          resource :
            name : "Network01"
        "subnet0001" :
          type : "OS::Neutron::Subnet"
          uid  : "subnet0001"
          resource :
            name        : "Subnet01"
            network_id  : "@{network0001.resource.id}"
            allocation_pools : [{start:"10.0.0.10", end:"10.0.0.30"}]
        "subnet0002" :
          type : "OS::Neutron::Subnet"
          uid  : "subnet0002"
          resource :
            name        : "Subnet02"
            network_id  : "@{network0001.resource.id}"
            allocation_pools : [{start:"10.0.0.10", end:"10.0.0.30"}]
        "sg0001" :
          type : "OS::Neutron::SecurityGroup"
          uid  : "sg0001"
          resource :
            name  : "Sg01"
            rules : []
        "router0001" :
          type : "OS::Neutron::Router"
          uid  : "router0001"
          resource :
            external_gateway_info : { network_id : "1f0fd926-9c82-4536-b498-0c00a4133914"}
            router_interface : [{"subnet_id": "@{subnet0001.resource.id}"}]
        "pool0001" :
          type : "OS::Neutron::Pool"
          uid  : "pool0001"
          resource :
            name : "Pool01"
            subnet_id        : "@{subnet0002.resource.id}"
            healthmonitor_id : "@{monitor0001.resource.id}"
            member : [{address : "@{port0001.resource.fixed_ips.0.ip_address}"}]
        "listener0001" :
          type : "OS::Neutron::VIP"
          uid  : "listener0001"
          resource :
            name      : "Listener01"
            pool_id   : "@{pool0001.resource.id}"
            subnet_id : "@{subnet0001.resource.id}"
        "monitor0001" :
          type : "OS::Neutron::HealthMonitor"
          uid  : "monitor0001"
          resource :
            type : "HTTP"

      @__jsonData = json
      return
  }

  AwsOpsModel
