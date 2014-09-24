
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
      json.layout    =
        size : [ 240, 240 ]
        "extnetwork0001" :
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
        # "port0002" :
        #   coordinate : [ 65, 11 ]
        "pool0001" :
          coordinate : [ 65, 40 ]
        "listener0001" :
          coordinate : [ 42, 40 ]

      json.component =
        "extnetwork0001" :
          type : "OS::ExternalNetwork"
          uid  : "extnetwork0001"
          resource :
            name : "ExternalNetwork"
            id   : ""

        "server0001":
          type: "OS::Nova::Server"
          uid: "server0001"
          resource:
            name: "webserver"
            flavor: "6"
            image: "2e973595-7f72-4528-a69f-9cf070e445af"
            meta: ""
            userdata: ""
            availabilityZone: ""
            blockDeviceMapping: []
            key_name: "testkp"
            NICS: [
              {"port-id": "@{port0001.resource.id}"}
              # {"port-id": "@{port0002.resource.id}"}
            ]
            adminPass: "12345678"
            id: ""

        "network0001":
          type: "OS::Neutron::Network"
          uid: "network0001"
          resource:
            name           : "network1"
            admin_state_up : ""
            shared         : ""
            id             : ""

        "subnet0001":
          type: "OS::Neutron::Subnet"
          uid: "subnet0001"
          resource:
            name: "subnet1"
            network_id       : "@{network0001.resource.id}"
            allocation_pools : [
              start : "10.0.0.10"
              end   : "10.0.0.250"
            ]
            gateway_ip       : "10.0.0.1"
            ip_version       : "4"
            cidr             : "10.0.0.0/24"
            enable_dhcp      : true
            id               : ""

        "subnet0002" :
          type : "OS::Neutron::Subnet"
          uid  : "subnet0002"
          resource :
            name             : "subnet2"
            network_id       : "@{network0001.resource.id}"
            allocation_pools : [
              start : "10.0.1.10"
              end   : "10.0.1.250"
            ]
            gateway_ip       : "10.0.1.1"
            ip_version       : "4"
            cidr             : "10.0.1.0/24"
            enable_dhcp      : true
            id               : ""

        "port0001":
          type: "OS::Neutron::Port"
          uid: "port0001"
          resource:
            name: "port-1"
            admin_state_up: ""
            mac_address: ""
            fixed_ips: [
              subnet_id: "@{subnet0001.resource.id}"
              ip_address: "10.0.0.12"
            ]
            security_groups: ["@{sg0001.resource.id}"]
            network_id: "@{network0001.resource.id}"
            id: ""

        # "port0002" :
        #   type : "OS::Neutron::Port"
        #   uid  : "port0002"
        #   resource :
        #     name : "port-2"
        #     fixed_ips: [{
        #       "subnet_id"  : "@{subnet0002.resource.id}"
        #       "ip_address" : "10.0.1.12"
        #     }]
        #     security_groups : [ "@{sg0001.resource.id}"]
        #     network_id      : "@{network0001.resource.id}"

        "sg0001":
          type: "OS::Neutron::SecurityGroup"
          uid: "sg0001"
          resource:
            name: "DefaultSG"
            description: "default security group"
            rules: [
              direction: "egress"
              ethertype: "IPv4"
              port_range_min: null
              port_range_max: null
              protocol: null
              remote_group_id: null
              remote_ip_prefix: null
              id: ""
            ]
            id: ""

        "router0001":
          type: "OS::Neutron::Router"
          uid: "router0001"
          resource:
            name: "router1"
            external_gateway_info :
              network_id : "@{extnetwork0001.resource.id}"
            admin_state_up: true
            id: ""
            router_interface: [subnet_id: "@{subnet0001.resource.id}"]

        # "floating-ip-id":
        #   type: "OS::Neutron::FloatingIP"
        #   uid: "floating-ip-id"
        #   resource:
        #     floating_network_id: "1f0fd926-9c82-4536-b498-0c00a4133914"
        #     fixed_ip_address: "@{port0001.resource.fixed_ips.0.ip_address}"
        #     floating_ip_address: ""
        #     port_id: "@{port0001.resource.id}"
        #     id: ""

        "pool0001":
          type: "OS::Neutron::Pool"
          uid: "pool0001"
          resource:
            name: "pool1"
            protocol: "HTTP"
            lb_method: "ROUND_ROBIN"
            subnet_id: "@{subnet0002.resource.id}"
            healthmonitors : ["@{healthmonitor0001.resource.id}"]
            member: [
              protocol_port: 80
              address: "@{port0001.resource.fixed_ips.0.ip_address}"
              weight: 1
              id: ""
            ]
            id: ""

        "listener0001":
          type: "OS::Neutron::VIP"
          uid: "listener0001"
          resource:
            name: "listener1"
            pool_id: "@{pool0001.resource.id}"
            subnet_id: "@{subnet0001.resource.id}"
            connection_limit: "1000"
            protocol: "HTTP"
            protocol_port: "80"
            admin_state_up: ""
            address: "10.0.0.20"
            port_id: ""
            security_groups : [ "@{sg0001.resource.id}"]
            id: ""

        "healthmonitor0001":
          type: "OS::Neutron::HealthMonitor"
          uid: "healthmonitor0001"
          resource:
            type: "HTTP"
            delay: 30
            timeout: 30
            max_retries: 3
            url_path: "/index.html"
            expected_codes: "200-299"
            id: ""

        "volume0001":
          type: "OS::Cinder::Volume"
          uid: "volume0001"
          resource:
            availability_zone: ""
            source_volid: ""
            display_description: "test"
            snapshot_id: ""
            size: 1
            display_name: "vol1"
            imageRef: ""
            volume_type: ""
            bootable: ""
            server_id: "@{server0001.resource.id}"
            mount_point: "/dev/sdf"
            id: ""


      @__jsonData = json
      return
  }

  AwsOpsModel
