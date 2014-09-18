
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

    __initJsonData : ()->
      json = @__createRawJson()
      json.layout    =
        size : [ 240, 240 ]
        "extnetwork001" :
          coordinate : [ 5, 5 ]
        "router-id" :
          coordinate : [ 20, 5 ]
        "network-id" :
          coordinate : [ 34, 3 ]
          size       : [ 60, 60 ]
        "subnet-id" :
          coordinate : [ 36, 6 ]
          size       : [ 20, 50 ]
        "subnet0002" :
          coordinate : [ 60, 6 ]
          size       : [ 20, 50 ]
        "server-id" :
          coordinate : [ 42, 10 ]
        "port0002" :
          coordinate : [ 65, 11 ]
        "pool-id" :
          coordinate : [ 65, 40 ]
        "listener-id" :
          coordinate : [ 42, 40 ]

      json.component =
        "extnetwork001" :
          type : "OS::ExternalNetwork"
          uid  : "extnetwork001"
          resource :
            name : "ExternalNetwork"
            id   : ""

        "server-id":
          type: "OS::Nova::Server"
          uid: "server-id"
          resource:
            name: "helloworldserver"
            flavor: "6"
            image: "2e973595-7f72-4528-a69f-9cf070e445af"
            meta: ""
            userdata: ""
            availabilityZone: ""
            blockDeviceMapping: []
            key_name: "testkp"
            NICS: [
              {"port-id": "@{port-id.resource.id}"}
              {"port-id": "@{port0002.resource.id}"}
            ]
            adminPass: "12345678"
            id: ""

        "network-id":
          type: "OS::Neutron::Network"
          uid: "network-id"
          resource:
            name: "helloworldnetwork"
            admin_state_up: ""
            shared: ""
            id: ""

        "subnet-id":
          type: "OS::Neutron::Subnet"
          uid: "subnet-id"
          resource:
            name: "helloworldsubnet"
            network_id: "@{network-id.resource.id}"
            allocation_pools: [
              start: "10.0.0.10"
              end: "10.0.0.30"
            ]
            gateway_ip: "10.0.0.1"
            ip_version: "4"
            cidr: "10.0.0.0/24"
            enable_dhcp: true
            id: ""

        "subnet0002" :
          type : "OS::Neutron::Subnet"
          uid  : "subnet0002"
          resource :
            name             : "Subnet02"
            network_id       : "@{network-id.resource.id}"
            allocation_pools : [{start:"10.1.0.40", end:"10.1.0.50"}]
            gateway_ip       : "10.1.0.1"
            ip_version       : "4"
            cidr             : "10.1.0.0/24"
            enable_dhcp      : true

        "port-id":
          type: "OS::Neutron::Port"
          uid: "port-id"
          resource:
            name: "helloworldport"
            admin_state_up: ""
            mac_address: ""
            fixed_ips: [
              subnet_id: "@{subnet-id.resource.id}"
              ip_address: "10.0.0.12"
            ]
            security_groups: ["@{C0F3722B-94C8-4F03-8DF1-6B8AF41F0939.resource.id}"]
            network_id: "@{network-id.resource.id}"
            id: ""

        "port0002" :
          type : "OS::Neutron::Port"
          uid  : "port0002"
          resource :
            name : "Port02"
            fixed_ips: [{
              "subnet_id"  : "@{subnet0002.resource.id}"
              "ip_address" : "10.0.0.13"
            }]
            security_groups : [ "@{C0F3722B-94C8-4F03-8DF1-6B8AF41F0939.resource.id}"]
            network_id      : "@{network-id.resource.id}"

        "C0F3722B-94C8-4F03-8DF1-6B8AF41F0939":
          type: "OS::Neutron::SecurityGroup"
          uid: "C0F3722B-94C8-4F03-8DF1-6B8AF41F0939"
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

        "router-id":
          type: "OS::Neutron::Router"
          uid: "router-id"
          resource:
            name: "helloworldrouter"
            external_gateway_info :
              network_id : "@{extnetwork001.resource.id}"
            admin_state_up: true
            id: ""
            router_interface: [subnet_id: "@{subnet-id.resource.id}"]

        # "floating-ip-id":
        #   type: "OS::Neutron::FloatingIP"
        #   uid: "floating-ip-id"
        #   resource:
        #     floating_network_id: "1f0fd926-9c82-4536-b498-0c00a4133914"
        #     fixed_ip_address: "@{port-id.resource.fixed_ips.0.ip_address}"
        #     floating_ip_address: ""
        #     port_id: "@{port-id.resource.id}"
        #     id: ""

        "pool-id":
          type: "OS::Neutron::Pool"
          uid: "pool-id"
          resource:
            name: "hellworldpool"
            protocol: "HTTP"
            lb_method: "ROUND_ROBIN"
            subnet_id: "@{subnet0002.resource.id}"
            healthmonitors : ["@{healthmonitor-id.resource.id}"]
            member: [
              protocol_port: 80
              address: "@{port-id.resource.fixed_ips.0.ip_address}"
              weight: 1
              id: ""
            ]
            id: ""

        "listener-id":
          type: "OS::Neutron::VIP"
          uid: "listener-id"
          resource:
            name: "helloworldlistener"
            pool_id: "@{pool-id.resource.id}"
            subnet_id: "@{subnet-id.resource.id}"
            connection_limit: "1000"
            protocol: "HTTP"
            protocol_port: "80"
            admin_state_up: ""
            address: "10.0.0.20"
            port_id: ""
            id: ""

        "healthmonitor-id":
          type: "OS::Neutron::HealthMonitor"
          uid: "healthmonitor-id"
          resource:
            type: "HTTP"
            delay: 30
            timeout: 30
            max_retries: 3
            url_path: "/index.html"
            expected_codes: "200-299"
            id: ""

        "volume-id":
          type: "OS::Cinder::Volume"
          uid: "volume-id"
          resource:
            availability_zone: ""
            source_volid: ""
            display_description: "test"
            snapshot_id: ""
            size: 30
            display_name: "helloworldvolume"
            imageRef: ""
            volume_type: ""
            bootable: ""
            server_id: "@{server-id.resource.id}"
            mount_point: "/dev/sdf"
            id: ""


      @__jsonData = json
      return
  }

  AwsOpsModel
