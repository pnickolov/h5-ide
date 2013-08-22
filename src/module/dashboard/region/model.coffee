#############################
#  View Mode for dashboard(region)
#############################

define [ 'MC', 'backbone', 'jquery', 'underscore', 'event', 'app_model', 'stack_model', 'aws_model', 'ami_service', 'elb_service', 'dhcp_service', 'vpngateway_service', 'customergateway_service', 'vpc_model', 'constant' ], (MC, Backbone, $, _, ide_event, app_model, stack_model, aws_model, ami_service, elb_service, dhcp_service, vpngateway_service, customergateway_service, vpc_model, constant) ->

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
            "DescribeAutoScalingGroups":
                "status": [ "state" ],
                "title": "AutoScalingGroupName",
                "sub_info":[
                    { "key": [ "AutoScalingGroupName" ], "show_key": "AutoScalingGroupName"},
                    { "key": [ "type" ], "show_key": "Type"},
                    {"key": [ "Status" ], "show_key": "Status"}
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
            "DescribeAutoScalingGroups":
                "title" : "AutoScalingGroupName"
                "sub_info":[
                    {"key": [ "AutoScalingGroupName" ], "show_key": "AutoScalingGroupName"}
                    {"key": [ "AutoScalingGroupARN" ], "show_key": "AutoScalingGroupARN"}
                    {"key": [ "AvailabilityZones", "member" ], "show_key": "AvailabilityZones"}
                    {"key": [ "CreatedTime" ], "show_key": "CreatedTime"}
                    {"key": [ "DefaultCooldown" ], "show_key": "DefaultCooldown"}
                    {"key": [ "DesiredCapacity" ], "show_key": "DesiredCapacity"}
                    {"key": [ "EnabledMetrics" ], "show_key": "EnabledMetrics"}
                    {"key": [ "HealthCheckGracePeriod" ], "show_key": "HealthCheckGracePeriod"}
                    {"key": [ "HealthCheckType" ], "show_key": "HealthCheckType"}
                    {"key": [ "Instances" ], "show_key": "Instances"}
                    {"key": [ "LaunchConfigurationName" ], "show_key": "LaunchConfigurationName"}
                    {"key": [ "LoadBalancerNames", 'member' ], "show_key": "LoadBalancerNames"}
                    {"key": [ "MaxSize" ], "show_key": "MaxSize"}
                    {"key": [ "MinSize" ], "show_key": "MinSize"}
                    {"key": [ "Status" ], "show_key": "Status"}
                    {"key": [ "TerminationPolicies", 'member' ], "show_key": "TerminationPolicies"}
                    {"key": [ "VPCZoneIdentifier" ], "show_key": "VPCZoneIdentifier"}

                ]

            "DescribeAlarms":
                "title" : "AlarmName"
                "sub_info":[
                    {"key": [ "ActionsEnabled" ], "show_key": "ActionsEnabled"}
                    {"key": [ "AlarmActions", "member" ], "show_key": "AlarmActions"}
                    {"key": [ "AlarmArn" ], "show_key": "AlarmArn"}
                    {"key": [ "AlarmDescription" ], "show_key": "AlarmDescription"}
                    {"key": [ "AlarmName" ], "show_key": "AlarmName"}
                    {"key": [ "ComparisonOperator" ], "show_key": "ComparisonOperator"}
                    {"key": [ "Dimensions" ], "show_key": "Dimensions"}
                    {"key": [ "EvaluationPeriods" ], "show_key": "EvaluationPeriods"}
                    {"key": [ "InsufficientDataActions" ], "show_key": "InsufficientDataActions"}
                    {"key": [ "MetricName" ], "show_key": "MetricName"}
                    {"key": [ "Namespace" ], "show_key": "Namespace"}
                    {"key": [ "OKActions" ], "show_key": "OKActions"}
                    {"key": [ "Period" ], "show_key": "Period"}
                    {"key": [ "Statistic" ], "show_key": "Statistic"}
                    {"key": [ "StateValue" ], "show_key": "StateValue"}
                    {"key": [ "Threshold" ], "show_key": "Threshold"}
                    {"key": [ "Unit" ], "show_key": "Unit"}
                ]

            "ListSubscriptions":

                "title" :   "Endpoint"
                "sub_info" : [
                    {"key": [ "Endpoint" ], "show_key": "Endpoint"}
                    {"key": [ "Owner" ], "show_key": "Owner"}
                    {"key": [ "Protocol" ], "show_key": "Protocol"}
                    {"key": [ "SubscriptionArn" ], "show_key": "SubscriptionArn"}
                    {"key": [ "TopicArn" ], "show_key": "TopicArn"}

                ]

    #websocket
    ws = MC.data.websocket

    #private
    RegionModel = Backbone.Model.extend {

        defaults :
            'cur_app_list'          : null
            'cur_stack_list'        : null
            'region_resource_list'  : null
            'region_resource'       : null
            'resourse_list'         : null
            'vpc_attrs'             : null
            'unmanaged_list'        : null
            'status_list'           : null


        initialize : ->
            me = this

            #listen AWS_RESOURCE_RETURN
            me.on 'AWS_RESOURCE_RETURN', ( result ) ->

                if !result.is_error

                    console.log 'AWS_RESOURCE_RETURN'

                    region = result.param[3]

                    resource_source = if result.resolved_data[region] then result.resolved_data[region] else null

                    if resource_source

                        me.setResource resource_source, region
                        me.updateUnmanagedList()

                else
                    #TO-DO

                null


            #listen APP_START_RETURN
            # me.on 'APP_START_RETURN', (result) ->

            #     console.log 'APP_START_RETURN'

            #     # update tab icon
            #     ide_event.trigger ide_event.UPDATE_TAB_ICON, 'pending', app_id

            #     #parse the result
            #     if !result.is_error #request successfuly

            #         if ws
            #             req_id = result.resolved_data.id
            #             console.log "request id:" + req_id
            #             query = ws.collection.request.find({id:req_id})
            #             handle = query.observeChanges {
            #                 changed : (id, req) ->
            #                     if req.state == "Done"
            #                         handle.stop()
            #                         console.log 'stop handle'
            #                         #push event
            #                         ide_event.trigger ide_event.APP_RUN, app_name, app_id

            #                         # update icon
            #                         ide_event.trigger ide_event.UPDATE_TAB_ICON, 'running', app_id
            #             }
            #         null

            # #listen APP_STOP_RETURN
            # me.on 'APP_STOP_RETURN', (result) ->

            #     console.log 'APP_STOP_RETURN'

            #     # update tab icon
            #     ide_event.trigger ide_event.UPDATE_TAB_ICON, 'pending', app_id

            #     if !result.is_error
            #         if ws
            #             req_id = result.resolved_data.id
            #             console.log "request id:" + req_id
            #             query = ws.collection.request.find({id:req_id})
            #             handle = query.observeChanges {
            #                 changed : (id, req) ->
            #                     if req.state == "Done"
            #                         handle.stop()
            #                         console.log 'stop handle'
            #                         #push event
            #                         ide_event.trigger ide_event.APP_STOP, app_name, app_id

            #                         # update icon
            #                         ide_event.trigger ide_event.UPDATE_TAB_ICON, 'stopped', app_id

            #             }
            #         null

            # #listen APP_TERMINATE_RETURN
            # me.on 'APP_TERMINATE_RETURN', (result) ->

            #     console.log 'APP_TERMINATE_RETURN'

            #     # update tab icon
            #     ide_event.trigger ide_event.UPDATE_TAB_ICON, 'pending', app_id

            #     if !result.is_error
            #         if ws
            #             req_id = result.resolved_data.id
            #             console.log "request id:" + req_id
            #             query = ws.collection.request.find({id:req_id})
            #             handle = query.observeChanges {
            #                 changed : (id, req) ->
            #                     if req.state == "Done"
            #                         handle.stop()
            #                         console.log 'stop handle'
            #                         #push event
            #                         ide_event.trigger ide_event.APP_TERMINATE, app_name, app_id
            #             }
            #     null

            #listen STACK_SAVE__AS_RETURN
            # me.on 'STACK_SAVE__AS_RETURN', (result) ->
            #     console.log 'STACK_SAVE__AS_RETURN'

            #     if !result.is_error

            #         region      = result.param[3]
            #         id          = result.param[4]
            #         new_name    = result.param[5]
            #         name        = result.param[6]

            #         #update stack name list
            #         if new_name not in MC.data.stack_list[region]
            #             MC.data.stack_list[region].push new_name

            #         ide_event.trigger ide_event.UPDATE_STACK_LIST

            #     null

            # #listen STACK_REMOVE_RETURN
            # me.on 'STACK_REMOVE_RETURN', (result) ->
            #     console.log 'STACK_REMOVE_RETURN'
            #     console.log result

            #     if !result.is_error

            #         region  = result.param[3]
            #         id      = result.param[4]
            #         name    = result.param[5]

            #         ide_event.trigger ide_event.STACK_DELETE, name, id


            #listen VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN
            me.on 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', ( result ) ->

                console.log 'region_VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'

                regionAttrSet = result.resolved_data[current_region].accountAttributeSet.item[0].attributeValueSet.item

                if regionAttrSet.length == 2
                    vpc_attrs_value = { 'classic' : 'Classic', 'vpc' : 'VPC' }
                else
                    vpc_attrs_value = { 'vpc' : 'VPC' }

                me.set 'vpc_attrs', vpc_attrs_value

                null

            #listen AWS_STATUS_RETURN
            me.on 'AWS_STATUS_RETURN', ( result ) ->

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

        # reset the empty resultset when enter a second region
        resetData : ->
            me = this

            time_stamp      = new Date().getTime() / 1000
            unmanaged_list  = { loading:true, "time_stamp": time_stamp, "items": [] }
            me.set 'unmanaged_list', unmanaged_list
            me.set 'vpc_attrs', {}
            me.set 'status_list', {}


            lists = {loading:true, ELB:0, EIP:0, Instance:0, VPC:0, VPN:0, Volume:0}
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

        # get current region's app/stack list
        getItemList : ( flag, region, result ) ->
            me = this

            item_list = regions.region_name_group for regions in result when constant.REGION_LABEL[ region ] == regions.region_group

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
                        me.trigger 'UPDATE_REGION_APP_LIST'

                else if flag == 'stack'
                    if _.difference me.get('cur_stack_list'), cur_item_list
                        me.set 'cur_stack_list', cur_item_list
                        me.trigger 'UPDATE_REGION_STACK_LIST'

        parseItem : (item, flag) ->
            me = this

            id          = item.id
            name        = item.name
            create_time = item.time_create
            id_code     = item.key

            update_time =  Math.round(+new Date())

            status      = "play"
            isrunning   = true
            ispending   = false

            # check state
            if item.state == constant.APP_STATE.APP_STATE_INITIALIZING    #constant.APP_STATE.APP_STATE_STOPPING or
                return
            else if item.state == constant.APP_STATE.APP_STATE_RUNNING
                status = "play"
            else if item.state == constant.APP_STATE.APP_STATE_STOPPED
                isrunning = false
                status = "stop"
            else
                status = "pending"
                ispending = true

            has_instance_store_ami = false

            if flag == 'app'
                date = new Date()
                start_time = null
                stop_time = null

                has_instance_store_ami = if 'has_instance_store_ami' of item and item.has_instance_store_ami then item.has_instance_store_ami else false

                if item.last_start
                    date.setTime(item.last_start*1000)
                    start_time  = "GMT " + MC.dateFormat(date, "hh:mm yyyy-MM-dd")
                if not isrunning and item.last_stop
                    date.setTime(item.last_stop*1000)
                    stop_time = "GMT " + MC.dateFormat(date, "hh:mm yyyy-MM-dd")

            return { 'id' : id, 'code' : id_code, 'update_time' : update_time , 'name' : name, 'create_time':create_time, 'start_time' : start_time, 'stop_time' : stop_time, 'isrunning' : isrunning, 'ispending' : ispending, 'status' : status, 'cost' : "$0/month", 'has_instance_store_ami' : has_instance_store_ami }

        updateAppList : (flag, app_id) ->
            me = this

            cur_app_list = me.get 'cur_app_list'

            if flag is 'pending'
                for item in cur_app_list
                    if item.id == app_id
                        idx = cur_app_list.indexOf item
                        if idx>=0
                            cur_app_list[idx].status = "pending"
                            cur_app_list[idx].ispending = true

                            me.set 'cur_app_list', cur_app_list
                            me.trigger 'UPDATE_REGION_APP_LIST'

            null

        runApp : (region, app_id) ->
            me = this
            current_region = region

            app_name = i.name for i in me.get('cur_app_list') when i.id == app_id
            ide_event.trigger ide_event.START_APP, region, app_id, app_name

        stopApp : (region, app_id) ->
            me = this
            current_region = region

            app_name = i.name for i in me.get('cur_app_list') when i.id == app_id
            ide_event.trigger ide_event.STOP_APP, region, app_id, app_name

        terminateApp : (region, app_id) ->
            me = this
            current_region = region

            app_name = i.name for i in me.get('cur_app_list') when i.id == app_id
            ide_event.trigger ide_event.TERMINATE_APP, region, app_id, app_name

        duplicateStack : (region, stack_id, new_name) ->
            console.log 'duplicateStack'
            me = this
            current_region = region

            stack_name = s.name for s in me.get('cur_stack_list') when s.id == stack_id

            ide_event.trigger ide_event.DUPLICATE_STACK, region, stack_id, new_name, stack_name


        deleteStack : (region, stack_id) ->
            me = this
            current_region = region

            stack_name = s.name for s in me.get('cur_stack_list') when s.id == stack_id
            ide_event.trigger ide_event.DELETE_STACK, region, stack_id, stack_name

        _genDhcp: (dhcp) ->

            me = this

            popup_key_set.unmanaged_bubble.DescribeDhcpOptions = {}

            popup_key_set.unmanaged_bubble.DescribeDhcpOptions.title = "dhcpOptionsId"

            popup_key_set.unmanaged_bubble.DescribeDhcpOptions.sub_info = []

            sub_info = popup_key_set.unmanaged_bubble.DescribeDhcpOptions.sub_info

            if dhcp.dhcpConfigurationSet

                _.map dhcp.dhcpConfigurationSet.item, ( item, i ) ->

                    _.map item.valueSet, ( it, j )->

                        sub_info.push { "key": ['dhcpConfigurationSet', 'item', i, 'valueSet', j], "show_key": item.key }

            me.parseSourceValue 'DescribeDhcpOptions', dhcp, "bubble", null

        reRenderRegionResource : () ->

            me = this

            me.trigger "REGION_RESOURCE_CHANGED", null

        _set_app_property : ( resource, resources, i, action) ->


            if resource.tagSet != undefined

                _.map resource.tagSet, ( tag ) ->

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
            resources_keys  = [ 'DescribeVolumes', 'DescribeLoadBalancers', 'DescribeInstances', 'DescribeVpnConnections', 'DescribeVpcs', 'DescribeAddresses', 'DescribeAutoScalingGroups' ]

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
                                when "DescribeAutoScalingGroups"
                                    unmanaged_list.items.push {
                                        'type': "Auto Scaling Group",
                                        'name': (if name then name else value.AutoScalingGroupName),
                                        'state': value.activity_state,
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

            if $.cookie('has_cred') is 'true'

                vpc_model.DescribeAccountAttributes { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null,  ["supported-platforms"]


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

            if !keys_to_parse
                console.log type + ' ' + name

            status_keys = if keys_to_parse.status then keys_to_parse.status else null

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
                    if $.type(cur_value) == 'object' or $.type(cur_value) == 'array'
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
                parse_btns  = MC.aws.vpn.generateDownload keys_to_parse.btns, value_to_parse
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

            if $.type(source) == 'object'
                tmp = []
                _.map source, ( value, key )->

                    if value != null

                        if $.type(value) == 'string'

                            tmp.push ( '\\"<dt>' + key + ': </dt><dd>' + value + '</dd>\\"')

                        else
                            tmp.push me._genBubble value, title, false

                parse_sub_info = tmp.join(', ')

                if entry

                    bubble_front    = '<a href=\\"javascript:void(0)\\" class=\\"bubble table-link\\" data-bubble-template=\\"bubbleRegionResourceInfo\\" data-bubble-data='
                    bubble_end      = '>'+title+'</a>'
                    parse_sub_info  = " &apos;{\\\"title\\\": \\\"" +title + '\\\" , \\\"sub_info\\\":[' + parse_sub_info + "]}&apos; "
                    parse_sub_info  = bubble_front + parse_sub_info + bubble_end

            if $.type(source) == 'array'

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

                        if $.type(value) == 'string'

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
            if val then val else ''

        setResource : ( resources, region ) ->

            #cache aws resource data
            MC.aws.aws.cacheResource resources, region

            if region != current_region

                return null

            me = this

            lists = {ELB:0, EIP:0, Instance:0, VPC:0, VPN:0, Volume:0, AutoScalingGroup:0, SNS:0, CW:0}

            lists.Not_Used = { 'EIP' : 0, 'Volume' : 0 , SNS:0, CW:0}

            owner = atob $.cookie( 'usercode' )

            # elb
            if resources.DescribeLoadBalancers

                lists.ELB = resources.DescribeLoadBalancers.length

                reg = /app-\w{8}/

                _.map resources.DescribeLoadBalancers, ( elb, i ) ->

                    #me._set_app_property elb, resources, i, 'DescribeLoadBalancers'

                    elb.detail = me.parseSourceValue 'DescribeLoadBalancers', elb, "detail", null

                    if not elb.Instances

                        elb.state = '0 of 0 instances in service'

                        elb.instance_state = []

                    else

                        #use elb_service to invoke api
                        elb_service.DescribeInstanceHealth { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  elb.LoadBalancerName, null, ( result ) ->

                            if !result.is_error
                            #DescribeInstanceHealth succeed

                                total = result.resolved_data.length

                                health = 0

                                (health++ if instance.state == "InService") for instance in result.resolved_data

                                _.map resources.DescribeLoadBalancers, ( elb, i ) ->

                                    if elb.LoadBalancerName == result.param[4]

                                        resources.DescribeLoadBalancers[i].state = "#{health} of #{total} instances in service"

                                        resources.DescribeLoadBalancers[i].instance_state = result.resolved_data

                                    null

                                me.reRenderRegionResource()

                            else
                            #DescribeInstanceHealth failed

                                console.log 'elb.DescribeInstanceHealth failed, error is ' + result.error_message


                    reg_result = elb.LoadBalancerName.match reg

                    if reg_result then elb.app = reg_result

                    null

            # sns
            if resources.ListSubscriptions

                _.map resources.ListSubscriptions, ( sub, i ) ->

                    lists.SNS+=1
                    sub.detail = me.parseSourceValue 'ListSubscriptions', sub, "detail", null

                    if sub.SubscriptionArn is 'PendingConfirmation'

                        sub.pending_state = 'PendingConfirmation'

                        lists.Not_Used.SNS+=1

                    else

                        sub.success_state = 'Success'

                    sub.topic = sub.TopicArn.split(":")[5]

                    null

            # autoscaling
            if resources.DescribeAutoScalingGroups

                _.map resources.DescribeAutoScalingGroups, ( asl, i ) ->
                    lists.AutoScalingGroup+=1

                    if asl.Tags
                        _.map asl.Tags.member, ( tag ) ->

                            if tag.Key == 'app'

                                asl.app = tag.Value

                            if tag.Key == 'app-id'

                                asl.app_id = tag.Value

                            if tag.Key == 'Created by' and tag.Value == owner

                                asl.owner = tag.Value

                            null

                    asl.detail = me.parseSourceValue 'DescribeAutoScalingGroups', asl, "detail", null

                    if resources.DescribeScalingActivities

                        $.each resources.DescribeScalingActivities, ( idx, activity ) ->

                            if activity.AutoScalingGroupName is asl.AutoScalingGroupName

                                asl.last_activity = activity.Cause

                                asl.activity_state = activity.StatusCode

                                return false

                    null

            # cloudwatch alarm
            if resources.DescribeAlarms

                _.map resources.DescribeAlarms, ( alarm, i ) ->

                    lists.CW+=1

                    alarm.dimension_display = alarm.Dimensions.member[0].Name + ':' + alarm.Dimensions.member[0].Value
                    alarm.threshold_display = "#{alarm.MetricName} #{alarm.ComparisonOperator} #{alarm.Threshold} for #{alarm.Period} seconds"

                    if alarm.StateValue is 'OK'

                        alarm.state_ok = true

                    else if alarm.StateValue is 'ALARM'
                        lists.Not_Used.CW += 1
                        alarm.state_alarm = true

                    else
                        alarm.state_insufficient = true

                    alarm.detail = me.parseSourceValue 'DescribeAlarms', alarm, "detail", null

                    null

            # eip
            if resources.DescribeAddresses

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
            if resources.DescribeInstances

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
                    ins.launchTime = MC.dateFormat(new Date(ins.launchTime),'yyyy-MM-dd hh:mm:ss')

                    is_managed = false

                    if ins.tagSet != undefined

                        _.map ins.tagSet, ( tag )->
                            if tag
                                if tag.key == 'app'

                                    is_managed = true

                                    resources.DescribeInstances[i].app = tag.value

                                if tag.key == 'name'

                                    resources.DescribeInstances[i].host = tag.value

                                if tag.key == 'Created by' and tag.value == owner

                                    resources.DescribeInstances[i].owner = tag.value

                            null

                    if not resources.DescribeInstances[i].host

                        resources.DescribeInstances[i].host = ''

                    null

                _.map resources.DescribeInstances, ( ins ) ->

                    if ins.app != undefined

                        manage_instances_id.push ins.instanceId

                        manage_instances_app[ins.instanceId] = ins.app

                    null

                # ami
                if ami_list.length != 0

                    #use ami_service to invoke api
                    ami_service.DescribeImages { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  ami_list, null, null, null, ( result ) ->

                        if !result.is_error
                        #DescribeImages succeed

                            region_ami_list = {}

                            if $.type(result.resolved_data) == 'array'

                                _.map result.resolved_data, ( ami ) ->

                                    region_ami_list[ami.imageId] = ami

                                    null

                            _.map resources.DescribeInstances, ( ins, i ) ->

                                ins.image = region_ami_list[ins.imageId]

                                null

                            me.reRenderRegionResource()

                        else
                        #DescribeImages failed

                            console.log 'ami.DescribeImages failed, error is ' + result.error_message


            # volume
            if resources.DescribeVolumes

                lists.Volume = resources.DescribeVolumes.length

                _.map resources.DescribeVolumes, ( vol, i )->

                    vol.detail = me.parseSourceValue 'DescribeVolumes', vol, "detail", null

                    vol.createTime = MC.dateFormat(new Date(vol.createTime),'yyyy-MM-dd hh:mm:ss')

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
            if resources.DescribeVpcs

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

                    #use dhcp_service to envoke api
                    dhcp_service.DescribeDhcpOptions { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  dhcp_set, null, ( result ) ->

                        if !result.is_error
                        #DescribeDhcpOptions succeed

                            dhcp_set = result.resolved_data.item

                            _.map resources.DescribeVpcs, ( vpc ) ->

                                if vpc.dhcpOptionsId == 'default'

                                    vpc.dhcp = '{"title": "default", "sub_info" : ["<dt>DhcpOptionsId: </dt><dd>None</dd>"]}'

                                if $.type(dhcp_set) == 'object'

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


                        else
                        #DescribeDhcpOptions failed

                            console.log 'dhcp.DescribeDhcpOptions failed, error is ' + result.error_message

                        null


            # vpn
            if resources.DescribeVpnConnections
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

                    #use service to invoke api
                    customergateway_service.DescribeCustomerGateways { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  cgw_set, null, ( result ) ->

                        if !result.is_error
                        #DescribeCustomerGateways succeed

                            cgw_set = result.resolved_data.item

                            _.map resources.DescribeVpnConnections, ( vpn ) ->

                                if $.type(cgw_set) == 'object'

                                    vpn.cgw = me.parseSourceValue 'DescribeCustomerGateways', cgw_set, "bubble", null

                                else

                                    _.map cgw_set, ( cgw ) ->

                                        if vpn.customerGatewayId == cgw.customerGatewayId

                                            vpn.cgw = me.parseSourceValue 'DescribeCustomerGateways', cgw, "bubble", null

                                        null

                                null

                            me.reRenderRegionResource()


                        else
                        #DescribeCustomerGateways failed

                            console.log 'customergateway.DescribeCustomerGateways failed, error is ' + result.error_message

                        null


                # get vgw detail
                if vgw_set.length != 0

                    #use vpngateway_service to invoke api
                    vpngateway_service.DescribeVpnGateways { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  vgw_set, null, ( result ) ->

                        if !result.is_error
                        #DescribeVpnGateways succeed

                            vgw_set = result.resolved_data.item

                            _.map resources.DescribeVpnConnections, ( vpn ) ->

                                if $.type(vgw_set) == 'object'

                                    vpn.vgw = me.parseSourceValue 'DescribeVpnGateways', vgw_set, "bubble", null

                                    null

                                else

                                    _.map vgw_set, ( vgw )->

                                        if vpn.vpnGatewayId == vgw.vpnGatewayId

                                            vpn.vgw = me.parseSourceValue 'DescribeVpnGateways', vgw, "bubble", null

                                        null
                                    null

                            me.reRenderRegionResource()


                        else
                        #DescribeVpnGateways failed

                            console.log 'vpngateway.DescribeVpnGateways failed, error is ' + result.error_message

                        null


            #console.log resources
            me.set 'region_resource', resources
            me.set 'region_resource_list', lists

        describeAWSResourcesService : ( region )->

            me = this

            current_region = region

            res_type = constant.AWS_RESOURCE

            resources = {}
            resources[res_type.INSTANCE]  =   {}
            resources[res_type.EIP]       =   {}
            resources[res_type.VOLUME]    =   {}
            resources[res_type.VPC]       =   {}
            resources[res_type.VPN]       =   {}
            resources[res_type.ELB]       =   {}
            resources[res_type.KP]        =   {}
            resources[res_type.SG]        =   {}
            resources[res_type.ACL]       =   {}
            resources[res_type.CGW]       =   {}
            resources[res_type.DHCP]      =   {}
            resources[res_type.ENI]       =   {}
            resources[res_type.IGW]       =   {}
            resources[res_type.RT]        =   {}
            resources[res_type.SUBNET]    =   {}
            resources[res_type.VGW]       =   {}
            #
            resources[res_type.ASG]       =   {}
            resources[res_type.ASL_LC]    =   {}
            resources[res_type.ASL_NC]    =   {}
            resources[res_type.ASL_SP]    =   {}
            resources[res_type.ASL_SA]    =   {}
            resources[res_type.CLW]       =   {}
            resources[res_type.SNS_SUB]   =   {}
            resources[res_type.SNS_TOPIC] =   {}
            resources[res_type.ASL_ACT]   =   {}


            aws_model.resource { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region,  resources



        describeAWSStatusService : ( region )->

            me = this

            current_region = region

            aws_model.status { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null

            null
    }

    model = new RegionModel()

    return model
