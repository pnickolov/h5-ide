
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
        "83F25207-4AC4-4B88-A320-D951AC4DF5DC" :
          coordinate : [ 5, 5 ]
        "23B00CA6-74C3-4A25-A3A8-274A33BD9D87" :
          coordinate : [ 20, 5 ]
        "2A6EB27F-9D7B-4324-A998-F4C87C2ED6A1" :
          coordinate : [ 34, 3 ]
          size       : [ 60, 60 ]
        "CC7676DB-BDB9-4F05-8AD1-DAA0DA3B3EF6" :
          coordinate : [ 36, 6 ]
          size       : [ 20, 50 ]
        "2B278175-83AF-4C65-9F1C-3D0570F86DA4" :
          coordinate : [ 60, 6 ]
          size       : [ 20, 50 ]
        "3DF9EDE3-41C6-4DB7-93B7-E0FBBB59B142" :
          coordinate : [ 42, 10 ]
        # "port0002" :
        #   coordinate : [ 65, 11 ]
        "B7BE7F97-7C59-42CD-ACE5-4EC09F2D88A3" :
          coordinate : [ 65, 40 ]
        "4627F42F-8DB9-436A-8272-EFE26816DDB1" :
          coordinate : [ 42, 40 ]

      json.component =
        "83F25207-4AC4-4B88-A320-D951AC4DF5DC" :
          type : "OS::ExternalNetwork"
          uid  : "83F25207-4AC4-4B88-A320-D951AC4DF5DC"
          resource :
            name : "ExternalNetwork"
            id   : ""

        "3DF9EDE3-41C6-4DB7-93B7-E0FBBB59B142":
          type: "OS::Nova::Server"
          uid: "3DF9EDE3-41C6-4DB7-93B7-E0FBBB59B142"
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
              {"port-id": "@{92C407D2-7B62-449F-83E7-E88D2A9B8369.resource.id}"}
              # {"port-id": "@{port0002.resource.id}"}
            ]
            adminPass: "12345678"
            id: ""

        "2A6EB27F-9D7B-4324-A998-F4C87C2ED6A1":
          type: "OS::Neutron::Network"
          uid: "2A6EB27F-9D7B-4324-A998-F4C87C2ED6A1"
          resource:
            name           : "network1"
            admin_state_up : ""
            shared         : ""
            id             : ""

        "CC7676DB-BDB9-4F05-8AD1-DAA0DA3B3EF6":
          type: "OS::Neutron::Subnet"
          uid: "CC7676DB-BDB9-4F05-8AD1-DAA0DA3B3EF6"
          resource:
            name: "subnet1"
            network_id       : "@{2A6EB27F-9D7B-4324-A998-F4C87C2ED6A1.resource.id}"
            allocation_pools : [
              start : "10.0.0.10"
              end   : "10.0.0.250"
            ]
            gateway_ip       : "10.0.0.1"
            ip_version       : "4"
            cidr             : "10.0.0.0/24"
            enable_dhcp      : true
            id               : ""

        "2B278175-83AF-4C65-9F1C-3D0570F86DA4" :
          type : "OS::Neutron::Subnet"
          uid  : "2B278175-83AF-4C65-9F1C-3D0570F86DA4"
          resource :
            name             : "subnet2"
            network_id       : "@{2A6EB27F-9D7B-4324-A998-F4C87C2ED6A1.resource.id}"
            allocation_pools : [
              start : "10.0.1.10"
              end   : "10.0.1.250"
            ]
            gateway_ip       : "10.0.1.1"
            ip_version       : "4"
            cidr             : "10.0.1.0/24"
            enable_dhcp      : true
            id               : ""

        "92C407D2-7B62-449F-83E7-E88D2A9B8369":
          type: "OS::Neutron::Port"
          uid: "92C407D2-7B62-449F-83E7-E88D2A9B8369"
          resource:
            name: "port-1"
            admin_state_up: ""
            mac_address: ""
            fixed_ips: [
              subnet_id: "@{CC7676DB-BDB9-4F05-8AD1-DAA0DA3B3EF6.resource.id}"
              ip_address: "10.0.0.12"
            ]
            security_groups: ["@{E8B4645B-2713-42BF-B8C6-80C83A272D70.resource.id}"]
            network_id: "@{2A6EB27F-9D7B-4324-A998-F4C87C2ED6A1.resource.id}"
            id: ""

        # "port0002" :
        #   type : "OS::Neutron::Port"
        #   uid  : "port0002"
        #   resource :
        #     name : "port-2"
        #     fixed_ips: [{
        #       "subnet_id"  : "@{2B278175-83AF-4C65-9F1C-3D0570F86DA4.resource.id}"
        #       "ip_address" : "10.0.1.12"
        #     }]
        #     security_groups : [ "@{E8B4645B-2713-42BF-B8C6-80C83A272D70.resource.id}"]
        #     network_id      : "@{2A6EB27F-9D7B-4324-A998-F4C87C2ED6A1.resource.id}"

        "E8B4645B-2713-42BF-B8C6-80C83A272D70":
          type: "OS::Neutron::SecurityGroup"
          uid: "E8B4645B-2713-42BF-B8C6-80C83A272D70"
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

        "23B00CA6-74C3-4A25-A3A8-274A33BD9D87":
          type: "OS::Neutron::Router"
          uid: "23B00CA6-74C3-4A25-A3A8-274A33BD9D87"
          resource:
            name: "router1"
            external_gateway_info :
              network_id : "@{83F25207-4AC4-4B88-A320-D951AC4DF5DC.resource.id}"
            admin_state_up: true
            id: ""
            router_interface: [subnet_id: "@{CC7676DB-BDB9-4F05-8AD1-DAA0DA3B3EF6.resource.id}"]

        # "floating-ip-id":
        #   type: "OS::Neutron::FloatingIP"
        #   uid: "floating-ip-id"
        #   resource:
        #     floating_network_id: "1f0fd926-9c82-4536-b498-0c00a4133914"
        #     fixed_ip_address: "@{92C407D2-7B62-449F-83E7-E88D2A9B8369.resource.fixed_ips.0.ip_address}"
        #     floating_ip_address: ""
        #     port_id: "@{92C407D2-7B62-449F-83E7-E88D2A9B8369.resource.id}"
        #     id: ""

        "B7BE7F97-7C59-42CD-ACE5-4EC09F2D88A3":
          type: "OS::Neutron::Pool"
          uid: "B7BE7F97-7C59-42CD-ACE5-4EC09F2D88A3"
          resource:
            name: "pool1"
            protocol: "HTTP"
            lb_method: "ROUND_ROBIN"
            subnet_id: "@{2B278175-83AF-4C65-9F1C-3D0570F86DA4.resource.id}"
            healthmonitors : ["@{1A63B8E1-0470-4BA7-84CC-E956F63C9F81.resource.id}"]
            member: [
              protocol_port: 80
              address: "@{92C407D2-7B62-449F-83E7-E88D2A9B8369.resource.fixed_ips.0.ip_address}"
              weight: 1
              id: ""
            ]
            id: ""

        "4627F42F-8DB9-436A-8272-EFE26816DDB1":
          type: "OS::Neutron::VIP"
          uid: "4627F42F-8DB9-436A-8272-EFE26816DDB1"
          resource:
            name: "listener1"
            pool_id: "@{B7BE7F97-7C59-42CD-ACE5-4EC09F2D88A3.resource.id}"
            subnet_id: "@{CC7676DB-BDB9-4F05-8AD1-DAA0DA3B3EF6.resource.id}"
            connection_limit: "1000"
            protocol: "HTTP"
            protocol_port: "80"
            admin_state_up: ""
            address: "10.0.0.20"
            port_id: ""
            security_groups : [ "@{E8B4645B-2713-42BF-B8C6-80C83A272D70.resource.id}"]
            id: ""

        "1A63B8E1-0470-4BA7-84CC-E956F63C9F81":
          type: "OS::Neutron::HealthMonitor"
          uid: "1A63B8E1-0470-4BA7-84CC-E956F63C9F81"
          resource:
            type: "HTTP"
            delay: 30
            timeout: 30
            max_retries: 3
            url_path: "/index.html"
            expected_codes: "200-299"
            id: ""

        "A54DA416-3BE1-40C7-9A44-B7616924D0C6":
          type: "OS::Cinder::Volume"
          uid: "A54DA416-3BE1-40C7-9A44-B7616924D0C6"
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
            server_id: "@{3DF9EDE3-41C6-4DB7-93B7-E0FBBB59B142.resource.id}"
            mount_point: "/dev/sdf"
            id: ""


      @__jsonData = json
      return
  }

  AwsOpsModel
