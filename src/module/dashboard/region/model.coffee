#############################
#  View Mode for dashboard(region)
#############################

define [ 'MC', 'backbone', 'jquery', 'underscore', 'event', 'app_model', 'stack_model', 'aws_model', 'ami_model', 'elb_model', 'dhcp_model', 'vpngateway_model', 'customergateway_model', 'vpc_model', 'constant' ], (MC, Backbone, $, _, ide_event, app_model, stack_model, aws_model, ami_model, elb_model, dhcp_model, vpngateway_model, customergateway_model, vpc_model, constant) ->

    current_region  = null
    resource_source = null
    vpc_attrs_value = null
    unmanaged_list  = null
    status_list     = null
    owner           = null

    update_timestamp = 0

    popup_key_set =
        "unmanaged_bubble" :
            "DescribeVolumes":
                "status": [ "status" ],
                "title": "volumeId",
                "sub_info":[
                    { "key": [ "createTime" ], "show_key": "Create Time"},
                    { "key": [ "availabilityZone" ], "show_key": "Availability Zone"},
                    { "key": [ "attachmentSet", "item", "status" ], "show_key": "Attachment Status"}
                ]
            "DescribeCustomerGateways":
                "title"     :   "customerGatewayId"
                "status"    :   "state"
                "sub_info"  :   [
                        { "key": [ "customerGatewayId" ], "show_key": "CustomerGatewayId"},
                        { "key": [ "type"], "show_key": "Type"},
                        { "key": [ "ipAddress"], "show_key": "IpAddress"},
                        { "key": [ "bgpAsn"], "show_key": "BgpAsn"},
                ]
            "DescribeVpnGateways":
                "title"     :   "vpnGatewayId"
                "status"    :   "state"
                "sub_info"  :   [
                        { "key": [ "vpnGatewayId" ], "show_key": "VPNGatewayId"},
                        { "key": [ "type"], "show_key": "Type"},
                ]
            "DescribeInstances":
                "status": [ "instanceState", "name" ],
                "title": "instanceId",
                "sub_info":[
                    { "key": [ "launchTime" ], "show_key": "Launch Time"},
                    { "key": [ "placement", "availabilityZone" ], "show_key": "Availability Zone"}
                ]
            "DescribeVpnConnections":
                "status": [ "state" ],
                "title": "vpnConnectionId",
                "sub_info":[
                    { "key": [ "vpnConnectionId" ], "show_key": "VPC"},
                    { "key": [ "type" ], "show_key": "Type"},
                    { "key": [ "routes", "item", "source" ], "show_key": "Routing"}
                ]
            "DescribeVpcs":
                "status": [ "state" ],
                "title": "vpcId",
                "sub_info":[
                    { "key": [ "cidrBlock" ], "show_key": "CIDR"},
                    { "key": [ "isDefault" ], "show_key": "Default VPC:"},
                    { "key": [ "instanceTenancy" ], "show_key": "Tenacy"}
                ]
        "detail" :
            "DescribeVolumes":
                "title": "volumeId",
                "sub_info":[
                    { "key": [ "volumeId" ], "show_key": "Volume ID"},
                    { "key": [ "attachmentSet", "item",0, "device"  ], "show_key": "Device Name"},
                    { "key": [ "snapshotId" ], "show_key": "Snapshot ID"},
                    { "key": [ "size" ], "show_key": "Volume Size(GiB)"}
                    { "key": [ "createTime" ], "show_key": "Create Time"},
                    { "key": [ "attachmentSet" ], "show_key": "AttachmentSet"},
                    { "key": [ "status" ], "show_key": "status"},
                    { "key": [ "attachmentSet", "item", "status" ], "show_key": "AttachmentSet"},
                    { "key": [ "availabilityZone" ], "show_key": "Availability Zone"},
                    { "key": [ "volumeType" ], "show_key": "Volume Type"},
                    { "key": [ "Iops" ], "show_key": "Iops"}
                ]
            "DescribeInstances":
                "title": "instanceId",
                "sub_info": [
                    { "key": [ "instanceState", "name" ], "show_key": "Status"},
                    { "key": [ "keyName" ], "show_key": "Key Pair Name"},
                    { "key": [ "monitoring", "state" ], "show_key": "Monitoring"},
                    { "key": [ "ipAddress" ], "show_key": "Primary Public IP"},
                    { "key": [ "dnsName" ], "show_key": "Public DNS"},
                    { "key": [ "privateIpAddress" ], "show_key": "Primary Private IP"},
                    { "key": [ "privateDnsName" ], "show_key": "Private DNS"},
                    { "key": [ "launchTime" ], "show_key": "Launch Time"},
                    { "key": [ "placement", "availabilityZone" ], "show_key": "Zone"},
                    { "key": [ "amiLaunchIndex" ], "show_key": "AMI Launch Index"},
                    { "key": [ "instanceType" ], "show_key": "Instance Type"},
                    { "key": [ "ebsOptimized" ], "show_key": "EBS Optimized"},
                    { "key": [ "rootDeviceType" ], "show_key": "Root Device Type"},
                    { "key": [ "placement", "tenancy" ], "show_key": "Tenancy"},
                    { "key": [ "blockDeviceMapping", "item"], "show_key": "Block Devices"}
                    { "key": ['networkInterfaceSet', 'item'], "show_key": "NetworkInterface"}
                ]
            "DescribeVpnConnections":
                "title": "vpnConnectionId",
                "sub_info": [
                    { "key": [ "state" ], "show_key": "State"},
                    { "key": [ "vpnGatewayId" ], "show_key": "Virtual Private Gateway"},
                    { "key": [ "customerGatewayId" ], "show_key": "Customer Gateway"},
                    { "key": [ "type" ], "show_key": "Type"},
                    { "key": [ "routes", "item", 0], "show_key": "Routing"}
                ],
                "btns": [
                    { "type": "download_configuration", "name": "Download Configuration" }
                    ],
                "detail_table": [
                    { "key": [ "vgwTelemetry", "item" ], "show_key": "VPN Tunnel", "count_name": "tunnel"},
                    { "key": [ "outsideIpAddress" ], "show_key": "IP Address"},
                    { "key": [ "status" ], "show_key": "Status"},
                    { "key": [ "lastStatusChange" ], "show_key": "Last Changed"},
                    { "key": [ "statusMessage" ], "show_key": "Detail"}
                ]
            "DescribeVpcs":
                "title": "vpcId",
                "sub_info": [
                    { "key": [ "state" ], "show_key": "State"},
                    { "key": [ "cidrBlock" ], "show_key": "CIDR"},
                    { "key": [ "instanceTenancy" ], "show_key": "Tenancy"}
                ]
            "DescribeLoadBalancers":
                "title": "LoadBalancerName",
                "sub_info":[
                    { "key": [ "state" ], "show_key": "State"},
                    { "key": [ "AvailabilityZones", "member" ], "show_key": "AvailabilityZones"},
                    { "key": [ "CreatedTime" ], "show_key": "CreatedTime"}
                    { "key": [ "DNSName" ], "show_key": "DNSName"}
                    { "key": [ "HealthCheck" ], "show_key": "HealthCheck"}
                    { "key": [ "Instances", 'member' ], "show_key": "Instances"}
                    { "key": [ "ListenerDescriptions", "member" ], "show_key": "ListenerDescriptions"}
                    { "key": [ "SecurityGroups", "member"], "show_key": "SecurityGroups"}
                    { "key": [ "Subnets", "member" ], "show_key": "Subnets"}
                ]
            "DescribeAddresses":
                "title": "publicIp",
                "sub_info":[
                    { "key": [ "domain" ], "show_key": "Domain"},
                    { "key": [ "instanceId" ], "show_key": "InstanceId"},
                    { "key": [ "publicIp" ], "show_key": "PublicIp"}
                    { "key": [ "associationId" ], "show_key": "AssociationId"}
                    { "key": [ "allocationId" ], "show_key": "AllocationId"}
                    { "key": [ "networkInterfaceId"], "show_key": "NetworkInterfaceId"}
                    { "key": [ "privateIpAddress"], "show_key": "PrivateIpAddress"}
                    { "key": [ "SecurityGroups"], "show_key": "SecurityGroups"}
                    { "key": [ "Subnets" ], "show_key": "Subnets"}
                ]

    #private
    RegionModel = Backbone.Model.extend {

        defaults :
            'cur_app_list'          : []
            'cur_stack_list'        : []
            'region_resource_list'  : null
            'region_resource'       : null
            'resourse_list'         : null
            'vpc_attrs'             : null
            'unmanaged_list'        : null
            'status_list'           : null


        initialize : ->
            me = this

            aws_model.on 'AWS_RESOURCE_RETURN', ( result ) ->

                console.log 'AWS_RESOURCE_RETURN'

                resource_source = result.resolved_data[current_region]

                me.setResource resource_source

                me.updateUnmanagedList()

                null

            ami_model.on 'EC2_AMI_DESC_IMAGES_RETURN', ( result ) ->

                region_ami_list = {}

                if result.resolved_data.item.constructor == Array

                    _.map result.resolved_data.item, ( ami ) ->

                        region_ami_list[ami.imageId] = ami

                        null

                _.map resource_source.DescribeInstances, ( ins, i ) ->

                    ins.image = region_ami_list[ins.imageId]

                    null

                me.reRenderRegionResource()

                null

            elb_model.on 'ELB__DESC_INS_HLT_RETURN', ( result ) ->

                total = result.resolved_data.length

                health = 0

                (health++ if instance.state == "InService") for instance in result.resolved_data

                _.map resource_source.DescribeLoadBalancers, ( elb, i ) ->

                    if elb.LoadBalancerName == result.param[4]

                        resource_source.DescribeLoadBalancers[i].state = "#{health} of #{total} instances in service"

                    null

                me.reRenderRegionResource()

                null

            dhcp_model.on 'VPC_DHCP_DESC_DHCP_OPTS_RETURN', ( result ) ->

                dhcp_set = result.resolved_data.item

                _.map resource_source.DescribeVpcs, ( vpc ) ->

                    if vpc.dhcpOptionsId == 'default'

                        vpc.dhcp = '{"title": "default", "sub_info" : ["<dt>DhcpOptionsId: </dt><dd>None</dd>"]}'

                    if dhcp_set.constructor == Object

                        if vpc.dhcpOptionsId == dhcp_set.dhcpOptionsId

                            vpc.dhcp = me._genDhcp dhcp_set

                    else

                        _.map dhcp_set, ( dhcp )->

                            if vpc.dhcpOptionsId == dhcp.dhcpOptionsId

                                vpc.dhcp = me._genDhcp dhcp

                                null

                    null

                me.reRenderRegionResource()

                #console.error me.parseSourceValue 'DescribeDhcpOptions', dhcp, "bubble", null

                null

            customergateway_model.on 'VPC_CGW_DESC_CUST_GWS_RETURN', ( result ) ->

                cgw_set = result.resolved_data.item

                _.map resource_source.DescribeVpnConnections, ( vpn ) ->

                    if cgw_set.constructor == Object

                        vpn.cgw = me.parseSourceValue 'DescribeCustomerGateways', cgw_set, "bubble", null

                    else

                        _.map cgw_set, ( cgw ) ->

                            if vpn.customerGatewayId == cgw.customerGatewayId

                                vpn.cgw = me.parseSourceValue 'DescribeCustomerGateways', cgw, "bubble", null

                            null

                    null

                me.reRenderRegionResource()

            vpngateway_model.on 'VPC_VGW_DESC_VPN_GWS_RETURN', ( result ) ->

                vgw_set = result.resolved_data.item

                _.map resource_source.DescribeVpnConnections, ( vpn ) ->

                    if vgw_set.constructor == Object

                        vpn.vgw = me.parseSourceValue 'DescribeVpnGateways', vgw_set, "bubble", null

                    else

                        _.map vgw_set, ( vgw )->

                            if vpn.vpnGatewayId == vgw.vpnGatewayId

                                vpn.vgw = me.parseSourceValue 'DescribeVpnGateways', vgw, "bubble", null

                            null
                    null

                me.reRenderRegionResource()

            null

        # reset the empty resultset when enter a second region
        resetData : ->
            me = this

            time_stamp      = new Date().getTime() / 1000
            unmanaged_list  = { "time_stamp": time_stamp, "items": [] }
            me.set 'unmanaged_list', unmanaged_list
            me.set 'vpc_attrs', {}
            me.set 'status_list', {}


            lists = {ELB:0, EIP:0, Instance:0, VPC:0, VPN:0, Volume:0}
            me.set 'region_resource_list', lists

            resource = {
                DescribeLoadBalancers:null
                DescribeInstances:null
                DescribeVpcs:null
                DescribeAddresses:null
                DescribeImages:null
                DescribeVpnGateways:null
            }
            me.set 'region_resource', resource

            # re render
            me.reRenderRegionResource()

        resultListListener : ->
            me = this
            null

            ###
            ide_event.onListen 'RESULT_APP_LIST', ( result ) ->

                # get current region's apps
                item_list = region.region_name_group for region in result when constant.REGION_LABEL[ current_region ] == region.region_group

                me.getItemList('app', item_list)

                null

            ide_event.onListen 'RESULT_STACK_LIST', ( result ) ->

                console.log 'RESULT_STACK_LIST'

                # get current region's stacks
                item_list = region.region_name_group for region in result when constant.REGION_LABEL[ current_region ] == region.region_group

                me.getItemList('stack', item_list)

                null
            ###

        # get current region's app/stack list
        getItemList : ( flag, item_list ) ->

            me = this

            cur_item_list = []
            _.map item_list, (value) ->
                item = me.parseItem(value, flag)
                if item
                    cur_item_list.push item

                    null

            if cur_item_list
                #sort
                cur_item_list.sort (a,b) ->
                    return if a.create_time <= b.create_time then 1 else -1

                if flag == 'app'
                    #difference
                    if _.difference me.get('cur_app_list'), cur_item_list
                        me.set 'cur_app_list', cur_item_list
                else if flag == 'stack'
                    if _.difference me.get('cur_stack_list'), cur_item_list
                        me.set 'cur_stack_list', cur_item_list

        parseItem : (item, flag) ->
            id          = item.id
            name        = item.name
            create_time = item.time_create

            status      = "play"
            isrunning   = true

            # check state
            if item.state == constant.APP_STATE.APP_STATE_STOPPING or item.state == constant.APP_STATE.APP_STATE_INITIALIZING
                return
            else if item.state == constant.APP_STATE.APP_STATE_RUNNING
                status = "play"
            else if item.state == constant.APP_STATE.APP_STATE_STOPPED
                isrunning = false
                status = "stop"
            else
                status = "pending"

            if flag == 'app'
                date = new Date()
                start_time = null
                stop_time = null
                if item.last_start
                    date.setTime(item.last_start*1000)
                    start_time  = "GMT " + MC.dateFormat(date, "hh:mm yyyy-MM-dd")
                if not isrunning and item.last_stop
                    date.setTime(item.last_stop*1000)
                    stop_time = "GMT " + MC.dateFormat(date, "hh:mm yyyy-MM-dd")

            return { 'id' : id, 'name' : name, 'create_time':create_time, 'start_time' : start_time, 'stop_time' : stop_time, 'isrunning' : isrunning, 'status' : status, 'cost' : "$0/month" }

        runApp : (region, app_id) ->
            me = this
            current_region = region

            app_name = i.name for i in me.get('cur_app_list') when i.id == app_id
            app_model.start { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, app_id, app_name
            app_model.on 'APP_START_RETURN', (result) ->
                console.log 'APP_START_RETURN'
                console.log result

                #parse the result
                if !result.is_error #request successfuly
                    #push event
                    ide_event.trigger ide_event.APP_RUN, app_name, app_id
                #else    # failed

        stopApp : (region, app_id) ->
            me = this
            current_region = region

            app_name = i.name for i in me.get('cur_app_list') when i.id == app_id
            app_model.stop { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, app_id, app_name
            app_model.on 'APP_STOP_RETURN', (result) ->
                console.log 'APP_STOP_RETURN'
                console.log result

                if !result.is_error
                    ide_event.trigger ide_event.APP_STOP, app_name, app_id

        terminateApp : (region, app_id) ->
            me = this
            current_region = region

            app_name = i.name for i in me.get('cur_app_list') when i.id == app_id
            app_model.terminate { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, app_id, app_name
            app_model.on 'APP_TERMINATE_RETURN', (result) ->
                console.log 'APP_TERMINATE_RETURN'
                console.log result

                if !result.is_error
                    ide_event.trigger ide_event.APP_TERMINATE, app_name, app_id

        duplicateStack : (region, stack_id, new_name) ->
            console.log 'duplicateStack'
            me = this
            current_region = region

            stack_name = s.name for s in me.get('cur_stack_list') when s.id == stack_id

            # get service, ( src, username, session_id, region_name, stack_id, new_name, stack_name=null )
            stack_model.save_as { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, stack_id, new_name, stack_name
            stack_model.once 'STACK_SAVE__AS_RETURN', (result) ->
                console.log 'STACK_SAVE__AS_RETURN'
                console.log result

                if !result.is_error
                    ide_event.trigger ide_event.UPDATE_STACK_LIST

        deleteStack : (region, stack_id) ->
            me = this
            current_region = region

            stack_name = s.name for s in me.get('cur_stack_list') when s.id == stack_id
            stack_model.remove { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, stack_id, stack_name
            stack_model.on 'STACK_REMOVE_RETURN', (result) ->
                console.log 'STACK_REMOVE_RETURN'
                console.log result

                if !result.is_error
                    ide_event.trigger ide_event.STACK_DELETE, stack_name, stack_id

        _genDhcp: (dhcp) ->

            me = this

            popup_key_set.unmanaged_bubble.DescribeDhcpOptions = {}

            popup_key_set.unmanaged_bubble.DescribeDhcpOptions.title = "dhcpOptionsId"

            popup_key_set.unmanaged_bubble.DescribeDhcpOptions.sub_info = []

            sub_info = popup_key_set.unmanaged_bubble.DescribeDhcpOptions.sub_info

            if dhcp.dhcpConfigurationSet.item.constructor == Array

                _.map dhcp.dhcpConfigurationSet.item, ( item, i ) ->

                    if item.valueSet.item.constructor == Array

                        _.map item.valueSet.item, ( it, j )->

                            sub_info.push { "key": ['dhcpConfigurationSet', 'item', i, 'valueSet', 'item', j, 'value'], "show_key": item.key }

                    else

                        sub_info.push { "key": [ 'dhcpConfigurationSet', 'item', i, 'valueSet', 'item', 'value'], "show_key": item.key }

            else
                item = dhcp.dhcpConfigurationSet.item

                if item.valueSet.item.constructor == Array

                    _.map item.valueSet.item, ( it, i ) ->

                        sub_info.push { "key": ['dhcpConfigurationSet', 'item', 'valueSet', 'item', j, 'value'], "show_key": item.key }

                else

                    sub_info.push { "key": ['dhcpConfigurationSet', 'item', 'valueSet', 'item', 'value'], "show_key": item.key }

            me.parseSourceValue 'DescribeDhcpOptions', dhcp, "bubble", null

                #sub_info.push { "key": [ dhcp.dhcpConfigurationSet.item.value], "show_key": dhcp.dhcpConfigurationSet.item.key }

        reRenderRegionResource : () ->

            me = this

            me.trigger "REGION_RESOURCE_CHANGED", null

        _set_app_property : ( resource, resources, i, action) ->


            if resource.tagSet != undefined and resource.tagSet.item.constructor == Array

                _.map resource.tagSet.item, ( tag ) ->

                    if tag.key == 'app'

                        resources[action][i].app = tag.value

                    if tag.key == 'Created by' and tag.value == owner

                        resources[action][i].owner = tag.value

                    null

            null


        #unmanaged_list
        updateUnmanagedList : ()->

            me = this

            time_stamp      = new Date().getTime() / 1000
            unmanaged_list  = { "time_stamp": time_stamp, "items": [] }
            resources_keys  = [ 'DescribeVolumes', 'DescribeLoadBalancers', 'DescribeInstances', 'DescribeVpnConnections', 'DescribeVpcs', 'DescribeAddresses' ]

            if resource_source
                #console.log resource_source
                _.map resources_keys, ( value ) ->

                    cur_attr    = resource_source[ value ]
                    cur_tag     = value

                    _.map cur_attr, ( value ) ->
                        if value.app is undefined
                            name = if value.tagSet then value.tagSet.name else null
                            switch cur_tag
                                when "DescribeVolumes"
                                    if !name
                                        if value.attachmentSet
                                            if value.attachmentSet.item
                                                name = value.attachmentSet.item.device
                                    unmanaged_list.items.push {
                                        'type': "Volume",
                                        'name': (if name then name else value.volumeId),
                                        'status': value.status,
                                        'cost': 0.00,
                                        'data-bubble-data': ( me.parseSourceValue cur_tag, value, "unmanaged_bubble", name ),
                                        'data-modal-data': ( me.parseSourceValue cur_tag, value, "detail", name)
                                    }
                                when "DescribeInstances"
                                    unmanaged_list.items.push {
                                        'type': "Instance",
                                        'name': (if name then name else value.instanceId),
                                        'status': value.instanceState.name,
                                        'cost': 0.00,
                                        'data-bubble-data': ( me.parseSourceValue cur_tag, value, "unmanaged_bubble", name ),
                                        'data-modal-data': ( me.parseSourceValue cur_tag, value, "detail", name)
                                    }
                                when "DescribeVpnConnections"
                                    unmanaged_list.items.push {
                                        'type': "VPN",
                                        'name': (if name then name else value.vpnConnectionId),
                                        'status': value.state,
                                        'cost': 0.00,
                                        'data-bubble-data': ( me.parseSourceValue cur_tag, value, "unmanaged_bubble", name ),
                                        'data-modal-data': ( me.parseSourceValue cur_tag, value, "detail", name)
                                    }
                                when "DescribeVpcs"
                                    unmanaged_list.items.push {
                                        'type': "VPC",
                                        'name': (if name then name else value.vpcId),
                                        'status': value.state,
                                        'cost': 0.00,
                                        'data-bubble-data': ( me.parseSourceValue cur_tag, value, "unmanaged_bubble", name ),
                                        'data-modal-data': ( me.parseSourceValue cur_tag, value, "detail", name)
                                    }
                                else
                        null
                    null

            me.set 'unmanaged_list', unmanaged_list

            null

        #vpc_attrs
        describeRegionAccountAttributesService : ( region )->

            me = this

            current_region = region

            vpc_model.DescribeAccountAttributes { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null,  ["supported-platforms"]

            vpc_model.once 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', ( result ) ->

                console.log 'region_VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'

                regionAttrSet = result.resolved_data[current_region].accountAttributeSet.item.attributeValueSet.item

                if $.type(regionAttrSet) == "array"
                    vpc_attrs_value = { 'classic' : 'Classic', 'vpc' : 'VPC' }
                else
                    vpc_attrs_value = { 'vpc' : 'VPC' }

                me.set 'vpc_attrs', vpc_attrs_value

                null

            null

        #parse bubble value or detail value for unmanagedSource
        parseSourceValue : ( type, value, keys, name )->

            me = this

            keys_to_parse  = null
            value_to_parse = value
            parse_result   = ''
            parse_sub_info = ''
            parse_table    = ''
            parse_btns     = ''

            keys_type      = keys

            if popup_key_set[keys]
                keys_to_parse = popup_key_set[keys_type][type]
            else
                keys_type     = "unmanaged_bubble"
                keys_to_parse = popup_key_set[keys_type][type]

            status_keys = keys_to_parse.status

            if status_keys
                state_key = status_keys[0]
                cur_state = value_to_parse[ state_key ]

                _.map status_keys, ( value, key ) ->
                    if cur_state
                        if key > 0
                            cur_state = cur_state[value]
                            if $.type(cur_state) == "array"
                                cur_state = cur_state[0]
                            null

                if cur_state
                    parse_result += '"status":"' + cur_state + '", '

            if keys_to_parse.title
                if keys isnt "detail"
                    if name
                        parse_result += '"title":"' + name
                        if value_to_parse[ keys_to_parse.title ]
                            parse_result += '-' + value_to_parse[ keys_to_parse.title ]
                            parse_result += '", '
                    else
                        if value_to_parse[ keys_to_parse.title ]
                            parse_result += '"title":"'
                            parse_result += value_to_parse[ keys_to_parse.title ]
                            parse_result += '", '
                else if keys is 'detail'
                    if name
                        parse_result += '"title":"' + name
                        if value_to_parse[ keys_to_parse.title ]
                            parse_result += '(' + value_to_parse[ keys_to_parse.title ]
                            parse_result += ')", '
                    else
                        if value_to_parse[ keys_to_parse.title ]
                            parse_result += '"title":"'
                            parse_result += value_to_parse[ keys_to_parse.title ]
                            parse_result += '", '

            _.map keys_to_parse.sub_info, ( value ) ->
                key_array = value.key
                show_key  = value.show_key
                cur_key   = key_array[0]
                cur_value = value_to_parse[ cur_key ]


                _.map key_array, ( value, key ) ->
                    if cur_value
                        if key > 0
                            cur_value = cur_value[value]
                            #if $.type(cur_value) is "array"
                            #    cur_value = cur_value[0]
                            cur_value

                if cur_value
                    if cur_value.constructor == Object or cur_value.constructor == Array
                        cur_value = me._genBubble cur_value, show_key, true

                    parse_sub_info += ( '"<dt>' + show_key + ': </dt><dd>' + cur_value + '</dd>", ')

                null

            if parse_sub_info
                parse_sub_info = '"sub_info":[' + parse_sub_info
                parse_sub_info = parse_sub_info.substring 0, parse_sub_info.length - 2
                parse_sub_info += ']'

            if keys_to_parse.detail_table
                parse_table = me._parseTableValue keys_to_parse.detail_table, value_to_parse
                if parse_table
                    parse_table = '"detail_table":' + parse_table
                    if parse_sub_info
                        parse_sub_info = parse_sub_info + ', ' + parse_table
                    else
                        parse_sub_info = parse_table

            if keys_to_parse.btns
                parse_btns  = me._parseBtnValue keys_to_parse.btns, value_to_parse
                if parse_btns
                    parse_btns = '"btns":' + parse_btns
                    if parse_sub_info
                        parse_sub_info = parse_sub_info + ', ' + parse_btns
                    else
                        parse_sub_info = parse_btns

            if parse_result
                parse_result = '{' + parse_result
                if parse_sub_info
                    parse_result += parse_sub_info
                else
                    parse_result = parse_result.substring 0, parse_result.length - 2
                parse_result += '}'

            parse_result

        _genBubble : ( source, title, entry ) ->

            me = this

            parse_sub_info = ""

            if $.isEmptyObject source

                return ""

            if source.constructor == Object
                tmp = []
                _.map source, ( value, key )->

                    if value != null

                        if value.constructor == String

                            tmp.push ( '\\"<dt>' + key + ': </dt><dd>' + value + '</dd>\\"')

                        else
                            tmp.push me._genBubble value, title, false

                parse_sub_info = tmp.join(', ')

                if entry

                    bubble_front    = '<a href=\\"javascript:void(0)\\" class=\\"bubble table-link\\" data-bubble-template=\\"bubbleRegionResourceInfo\\" data-bubble-data='
                    bubble_end      = '>'+title+'</a>'
                    parse_sub_info  = " &apos;{\\\"title\\\": \\\"" +title + '\\\" , \\\"sub_info\\\":[' + parse_sub_info + "]}&apos; "
                    parse_sub_info  = bubble_front + parse_sub_info + bubble_end

            if source.constructor == Array

                tmp = []

                titles = []

                is_str = false

                _.map source, ( value, index ) ->

                    current_title = title

                    if value.deviceName != undefined

                        current_title = value.deviceName

                    else if value.networkInterfaceId != undefined

                        current_title = value.networkInterfaceId

                    else if value.InstanceId != undefined

                        current_title = value.InstanceId
                    else if value.Listener != undefined

                        current_title = 'Listener' + '-' + index
                    else

                        current_title = title + '-' + index

                    titles.push current_title

                    if value != null

                        if value.constructor == String

                            is_str = true

                            tmp.push value

                        else

                            tmp.push me._genBubble value, current_title, false


                lines = []

                if entry
                    if not is_str

                        _.map tmp, ( line, index ) ->

                            bubble_front    = '<a href=\\"javascript:void(0)\\" class=\\"bubble table-link\\" data-bubble-template=\\"bubbleRegionResourceInfo\\" data-bubble-data='
                            bubble_end      = '>' + titles[index] + '</a>'
                            line            = " &apos;{\\\"title\\\": \\\"" + titles[index] + '\\\" , \\\"sub_info\\\":[' + line + "]}&apos; "
                            line            = bubble_front + line + bubble_end

                            lines.push line

                    else

                        lines = tmp

                else
                    lines = tmp

                parse_sub_info = lines.join(', ')

            parse_sub_info

        _parseTableValue : ( keyes_set, value_set )->
            me                  = this
            parse_table_result  = ''
            table_date          = ''

            detail_table =  [
                    { "key": [ "vgwTelemetry", "item" ], "show_key": "VPN Tunnel", "count_name": "tunnel"},
                    { "key": [ "outsideIpAddress" ], "show_key": "IP Address"},
                    { "key": [ "status" ], "show_key": "Status"},
                    { "key": [ "lastStatusChange" ], "show_key": "Last Changed"},
                    { "key": [ "statusMessage" ], "show_key": "Detail"},
                ]
            table_set = value_set.vgwTelemetry
            if table_set
                table_set = table_set.item
                if table_set
                    parse_table_result = '{ "th_set":['
                    _.map keyes_set, ( value, key ) ->
                        if key isnt 0
                            parse_table_result += ','
                        parse_table_result += '"'
                        parse_table_result += me._parseEmptyValue value.show_key
                        parse_table_result += '"'
                        null

                    _.map table_set, ( value, key ) ->
                        cur_key     = key
                        cur_value   = key + 1
                        parse_table_result += '], "tr'
                        parse_table_result += cur_value
                        parse_table_result += '_set":['
                        _.map keyes_set, ( value, key ) ->
                            if key isnt 0
                                parse_table_result += ',"'
                                parse_table_result += me._parseEmptyValue table_set[cur_key][value.key]
                                parse_table_result += '"'
                            else
                                parse_table_result += '"'
                                parse_table_result += me._parseEmptyValue value.count_name
                                parse_table_result += cur_value
                                parse_table_result += '"'
                            null
                        null
                    parse_table_result += ']}'
            parse_table_result

        _parseEmptyValue : ( val )->
            result = if val then val else ''
            result

        _parseBtnValue : ( keyes_set, value_set )->
            me                  = this
            parse_btns_result   = ''
            btn_data            = ''

            _.map keyes_set, ( value ) ->
                btn_data = ''

                if value.type is "download_configuration"
                    value_conf = value_set.customerGatewayConfiguration

                    if value_conf
                        value_conf = $.xml2json($.parseXML value_conf)
                        value_conf = value_conf.vpn_connection
                        dc_data =
                            vpnConnectionId                         : me._parseEmptyValue value_conf['@attributes'].id
                            vpnGatewayId                            : me._parseEmptyValue value_conf.vpn_gateway_id
                            customerGatewayId                       : me._parseEmptyValue value_conf.customer_gateway_id
                            tunnel                                  : []
                        _.map value_conf.ipsec_tunnel, ( value, key ) ->
                            cur_array = {}
                            cur_array.number                                 = key + 1
                            cur_array.ike_protocol_method                    = me._parseEmptyValue value_conf.ipsec_tunnel[key].ike.authentication_protocol
                            cur_array.ike_protocol_method                    = me._parseEmptyValue value_conf.ipsec_tunnel[key].ike.authentication_protocol
                            cur_array.ike_pre_shared_key                     = me._parseEmptyValue value_conf.ipsec_tunnel[key].ike.pre_shared_key,
                            cur_array.ike_authentication_protocol_algorithm  = me._parseEmptyValue value_conf.ipsec_tunnel[key].ike.authentication_protocol
                            cur_array.ike_encryption_protocol                = me._parseEmptyValue value_conf.ipsec_tunnel[key].ike.encryption_protocol
                            cur_array.ike_lifetime                           = me._parseEmptyValue value_conf.ipsec_tunnel[key].ike.lifetime
                            cur_array.ike_mode                               = me._parseEmptyValue value_conf.ipsec_tunnel[key].ike.mode
                            cur_array.ike_perfect_forward_secrecy            = me._parseEmptyValue value_conf.ipsec_tunnel[key].ike.perfect_forward_secrecy
                            cur_array.ipsec_protocol                         = me._parseEmptyValue value_conf.ipsec_tunnel[key].ipsec.protocol
                            cur_array.ipsec_authentication_protocol          = me._parseEmptyValue value_conf.ipsec_tunnel[key].ipsec.authentication_protocol
                            cur_array.ipsec_encryption_protocol              = me._parseEmptyValue value_conf.ipsec_tunnel[key].ipsec.encryption_protocol
                            cur_array.ipsec_lifetime                         = me._parseEmptyValue value_conf.ipsec_tunnel[key].ipsec.lifetime
                            cur_array.ipsec_mode                             = me._parseEmptyValue value_conf.ipsec_tunnel[key].ipsec.mode
                            cur_array.ipsec_perfect_forward_secrecy          = me._parseEmptyValue value_conf.ipsec_tunnel[key].ipsec.perfect_forward_secrecy
                            cur_array.ipsec_interval                         = me._parseEmptyValue value_conf.ipsec_tunnel[key].ipsec.dead_peer_detection.interval
                            cur_array.ipsec_retries                          = me._parseEmptyValue value_conf.ipsec_tunnel[key].ipsec.dead_peer_detection.retries
                            cur_array.tcp_mss_adjustment                     = me._parseEmptyValue value_conf.ipsec_tunnel[key].ipsec.tcp_mss_adjustment
                            cur_array.clear_df_bit                           = me._parseEmptyValue value_conf.ipsec_tunnel[key].ipsec.clear_df_bit
                            cur_array.fragmentation_before_encryption        = me._parseEmptyValue value_conf.ipsec_tunnel[key].ipsec.fragmentation_before_encryption
                            cur_array.customer_gateway_outside_address        = me._parseEmptyValue value_conf.ipsec_tunnel[key].customer_gateway.tunnel_outside_address.ip_address
                            cur_array.vpn_gateway_outside_address            = me._parseEmptyValue value_conf.ipsec_tunnel[key].vpn_gateway.tunnel_outside_address.ip_address
                            cur_array.customer_gateway_inside_address        = me._parseEmptyValue value_conf.ipsec_tunnel[key].customer_gateway.tunnel_inside_address.ip_address + '/' + value_conf.ipsec_tunnel[key].customer_gateway.tunnel_inside_address.network_cidr
                            cur_array.vpn_gateway_inside_address             = me._parseEmptyValue value_conf.ipsec_tunnel[key].vpn_gateway.tunnel_inside_address.ip_address + '/' + value_conf.ipsec_tunnel[key].customer_gateway.tunnel_inside_address.network_cidr
                            cur_array.next_hop                               = me._parseEmptyValue value_conf.ipsec_tunnel[key].vpn_gateway.tunnel_inside_address.ip_address

                            dc_data.tunnel.push cur_array

                            null

                        dc_filename = if dc_data.vpnConnectionId then dc_data.vpnConnectionId else 'download_configuration'
                        dc_data     = MC.template.configurationDownload(dc_data)
                        dc_parse    = '{"download":true,"filecontent":"'
                        dc_parse    +=  btoa(dc_data)
                        dc_parse    += '","filename":"'
                        dc_parse    += dc_filename
                        dc_parse    +='","btnname":"'
                        dc_parse    += value.name
                        dc_parse    += '"},'
                        btn_data    += dc_parse

                if btn_data
                    btn_data            = btn_data.substring 0, btn_data.length - 1
                    parse_btns_result   += '['
                    parse_btns_result   += btn_data
                    parse_btns_result   += ']'

            parse_btns_result

        setResource : ( resources ) ->

            me = this

            lists = {ELB:0, EIP:0, Instance:0, VPC:0, VPN:0, Volume:0}

            lists.Not_Used = { 'EIP' : 0, 'Volume' : 0 }

            owner = atob $.cookie( 'usercode' )

            # elb
            if resources.DescribeLoadBalancers != null

                lists.ELB = resources.DescribeLoadBalancers.length

                reg = /app-\w{8}/

                _.map resources.DescribeLoadBalancers, ( elb, i ) ->

                    #me._set_app_property elb, resources, i, 'DescribeLoadBalancers'

                    elb.detail = me.parseSourceValue 'DescribeLoadBalancers', elb, "detail", null

                    if not elb.Instances

                        elb.state = '0 of 0 instances in service'

                    else

                        elb_model.DescribeInstanceHealth { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  elb.LoadBalancerName

                    reg_result = elb.LoadBalancerName.match reg

                    if reg_result then elb.app = reg_result

                    null

            # eip
            if resources.DescribeAddresses != null

                _.map resources.DescribeAddresses, ( eip, i )->

                    if $.isEmptyObject eip.instanceId

                        lists.Not_Used.EIP++

                        resources.DescribeAddresses[i].instanceId = 'Not associated'

                    #me._set_app_property eip, resources, i, 'DescribeAddresses'

                    eip.detail = me.parseSourceValue 'DescribeAddresses', eip, "detail", null

                    null

                lists.EIP = resources.DescribeAddresses.length

            # managed instanceid
            manage_instances_id     =   []
            manage_instances_app    =   {}

            # instance
            if resources.DescribeInstances != null

                lists.Instance = resources.DescribeInstances.length

                ami_list = []

                _.map resources.DescribeInstances, ( ins, i ) ->

                    ami_list.push ins.imageId

                    #delete_index = []

                    #if ins.networkInterfaceSet

                    #    _.map ins.networkInterfaceSet.item, ( eni, eni_index )->

                    #        delete_index.push popup_key_set.detail.DescribeInstances.sub_info.push { "key": ['networkInterfaceSet', 'item', eni_index], "show_key": "NetworkInterface-" + eni_index }

                    ins.detail = me.parseSourceValue 'DescribeInstances', ins, "detail", null

                    #popup_key_set.detail.DescribeInstances.sub_info.pop() for j in delete_index

                    is_managed = false

                    if ins.tagSet != undefined and ins.tagSet.item.constructor == Array

                        _.map ins.tagSet.item, ( tag )->

                            if tag.key == 'app'

                                is_managed = true

                                resources.DescribeInstances[i].app = tag.value

                            if tag.key == 'name'

                                resources.DescribeInstances[i].host = tag.value

                            if tag.key == 'Created by' and tag.value == owner

                                resources.DescribeInstances[i].owner = tag.value

                            null

                    if resources.DescribeInstances[i].host == undefined

                        resources.DescribeInstances[i].host = ''

                    null

                _.map resources.DescribeInstances, ( ins ) ->

                    if ins.app != undefined

                        manage_instances_id.push ins.instanceId

                        manage_instances_app[ins.instanceId] = ins.app

                    null

                # ami
                if ami_list.length != 0

                    ami_model.DescribeImages { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  ami_list

            # volume
            if resources.DescribeVolumes != null

                lists.Volume = resources.DescribeVolumes.length

                _.map resources.DescribeVolumes, ( vol, i )->

                    vol.detail = me.parseSourceValue 'DescribeVolumes', vol, "detail", null

                    lists.Not_Used.Volume++ if vol.status == "available"

                    me._set_app_property vol, resources, i, 'DescribeVolumes'

                    if not vol.attachmentSet
                        vol.attachmentSet = {item:[]}

                        attachment = { device: 'not-attached', status: 'not-attached'}

                        vol.attachmentSet.item[0] = attachment
                    else

                        if vol.tagSet == undefined and vol.attachmentSet.item[0].instanceId in manage_instances_id

                            resources.DescribeVolumes[i].app = manage_instances_app[vol.attachmentSet.item[0].instanceId]

                            _.map resources.DescribeInstances, ( ins ) ->

                                if ins.instanceId == vol.attachmentSet.item[0].instanceId and ins.owner != undefined

                                    resources.DescribeVolumes[i].owner = ins.owner

                                null

                    null

            # vpc
            if resources.DescribeVpcs != null

                lists.VPC = resources.DescribeVpcs.length

                _.map resources.DescribeVpcs, ( vpc, i )->

                    me._set_app_property vpc, resources, i, 'DescribeVpcs'

                    vpc.detail = me.parseSourceValue 'DescribeVpcs', vpc, "detail", null

                    null

                dhcp_set = []

                _.map resources.DescribeVpcs, ( vpc )->

                    dhcp_set.push vpc.dhcpOptionsId if vpc.dhcpOptionsId not in dhcp_set and vpc.dhcpOptionsId != 'default'

                    null

                # get dhcp detail
                if dhcp_set.length != 0
                    dhcp_model.DescribeDhcpOptions { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  dhcp_set

            # vpn
            if resources.DescribeVpnConnections != null
                lists.VPN = resources.DescribeVpnConnections.length

                _.map resources.DescribeVpnConnections, ( vpn, i )->

                    me._set_app_property vpn, resources, i, 'DescribeVpnConnections'

                    vpn.detail = me.parseSourceValue 'DescribeVpnConnections', vpn, "detail", null

                    null

                cgw_set = []

                vgw_set = []

                _.map resources.DescribeVpnConnections, ( vpn ) ->

                    cgw_set.push vpn.customerGatewayId

                    vgw_set.push vpn.vpnGatewayId

                # get cgw detail
                if cgw_set.length != 0
                    customergateway_model.DescribeCustomerGateways { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  cgw_set

                # get vgw detail
                if vgw_set.length != 0
                    vpngateway_model.DescribeVpnGateways { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  vgw_set




            #console.log resources
            me.set 'region_resource', resources
            me.set 'region_resource_list', lists

        describeAWSResourcesService : ( region )->

            me = this

            current_region = region

            resources = [
                constant.AWS_RESOURCE.INSTANCE
                constant.AWS_RESOURCE.EIP
                constant.AWS_RESOURCE.VOLUME
                constant.AWS_RESOURCE.VPC
                constant.AWS_RESOURCE.VPN
                constant.AWS_RESOURCE.ELB
            ]

            aws_model.resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region,  resources

        describeAWSStatusService : ( region )->

            me = this

            current_region = region

            aws_model.status { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null

            aws_model.once 'AWS_STATUS_RETURN', ( result ) ->

                console.log 'AWS_STATUS_RETURN'

                status_list  = { red: 0, yellow: 0, info: 0 }
                service_list = constant.SERVICE_REGION[ current_region ]
                result_list  = result.resolved_data.current

                _.map result_list, ( value ) ->
                    service_set         = value
                    cur_service         = service_set.service
                    should_show_service = false

                    _.map service_list, ( value ) ->
                        if cur_service is value
                            should_show_service = true
                        null

                    if should_show_service
                        switch service_set.status
                            when '1'
                                status_list.red += 1
                                null
                            when '2'
                                status_list.yellow += 1
                                null
                            when '3'
                                status_list.info += 1
                                null
                            else
                                null

                me.set 'status_list', status_list

                null
            null
    }

    model = new RegionModel()

    return model