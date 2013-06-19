#############################
#  View Mode for dashboard(region)
#############################

define [ 'backbone', 'jquery', 'underscore', 'aws_model', 'ami_model', 'elb_model', 'dhcp_model', 'vpngateway_model', 'customergateway_model', 'vpc_model', 'constant' ], (Backbone, $, _, aws_model, ami_model, elb_model, dhcp_model, vpngateway_model, customergateway_model, vpc_model, constant) ->

    current_region  = null
    resource_source = null
    vpc_attrs_value = null
    unmanaged_list  = null
    status_list     = null

    update_timestamp = 0

    popup_key_set = {
        "unmanaged_bubble" : {
            "DescribeVolumes": {
                "status": [ "status" ],
                "title": "volumeId",
                "sub_info":[
                    { "key": [ "createTime" ], "show_key": "Create Time"},
                    { "key": [ "availabilityZone" ], "show_key": "Availability Zone"},
                    { "key": [ "attachmentSet", "item", "status" ], "show_key": "Attachment Status"}
                ]},
            "DescribeCustomerGateways": {
                "title"     :   "customerGatewayId"
                "status"    :   "state"
                "sub_info"  :   [
                        { "key": [ "customerGatewayId" ], "show_key": "CustomerGatewayId"},
                        { "key": [ "type"], "show_key": "Type"},
                        { "key": [ "ipAddress"], "show_key": "IpAddress"},
                        { "key": [ "bgpAsn"], "show_key": "BgpAsn"},
                    ]
                },
            "DescribeVpnGateways"   :   {
                "title"     :   "vpnGatewayId"
                "status"    :   "state"
                "sub_info"  :   [
                        { "key": [ "vpnGatewayId" ], "show_key": "VPNGatewayId"},
                        { "key": [ "type"], "show_key": "Type"},
                    ]
                }
            "DescribeInstances": {
                "status": [ "instanceState", "name" ],
                "title": "instanceId",
                "sub_info":[
                    { "key": [ "launchTime" ], "show_key": "Launch Time"},
                    { "key": [ "placement", "availabilityZone" ], "show_key": "Availability Zone"}
                ]},
            "DescribeVpnConnections": {
                "status": [ "state" ],
                "title": "vpnConnectionId",
                "sub_info":[
                    { "key": [ "vpnConnectionId" ], "show_key": "VPC"},
                    { "key": [ "type" ], "show_key": "Type"},
                    { "key": [ "routes", "item", "source" ], "show_key": "Routing"}
                ]},
            "DescribeVpcs": {
                "status": [ "state" ],
                "title": "vpcId",
                "sub_info":[
                    { "key": [ "cidrBlock" ], "show_key": "CIDR"},
                    { "key": [ "isDefault" ], "show_key": "Default VPC:"},
                    { "key": [ "instanceTenancy" ], "show_key": "Tenacy"}
                ]}
        },
        "detail" : {
            "DescribeVolumes": {
                "title": "volumeId",
                "sub_info":[
                    { "key": [ "volumeId" ], "show_key": "Volume ID"},
                    { "key": [ "attachmentSet", "item", "device"  ], "show_key": "Device Name"},
                    { "key": [ "snapshotId" ], "show_key": "Snapshot ID"},
                    { "key": [ "createTime" ], "show_key": "Create Time"},
                    { "key": [ "attachmentSet", "item", "attachTime"  ], "show_key": "Attach Name"},
                    { "key": [ "attachmentSet", "item", "deleteOnTermination" ], "show_key": "Delete On Termination"},
                    { "key": [ "attachmentSet", "item", "instanceId" ], "show_key": "Instance ID"},
                    { "key": [ "status" ], "show_key": "status"},
                    { "key": [ "attachmentSet", "item", "status" ], "show_key": "Attachment Status"},
                    { "key": [ "availabilityZone" ], "show_key": "Availability Zone"},
                    { "key": [ "volumeType" ], "show_key": "Volume Type"},
                    { "key": [ "Iops" ], "show_key": "Iops"}
                ]},
            "DescribeInstances": {
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
                    { "key": [ "blockDeviceMapping", "item", "deleteOnTermination"  ], "show_key": "Termination Protection"},
                    { "key": [ "blockDeviceMapping", "item", "status" ], "show_key": "Shutdown Behavior"},
                    { "key": [ "instanceType" ], "show_key": "Instance Type"},
                    { "key": [ "ebsOptimized" ], "show_key": "EBS Optimized"},
                    { "key": [ "rootDeviceType" ], "show_key": "Root Device Type"},
                    { "key": [ "placement", "tenancy" ], "show_key": "Tenancy"},
                    { "key": [ "networkInterfaceSet" ], "show_key": "Network Interface"},
                    { "key": [ "blockDeviceMapping", "item", "deviceName" ], "show_key": "Block Devices"},
                    { "key": [ "groupSet", "item", "groupName" ], "show_key": "Security Groups"}
                ]},
            "DescribeVpnConnections": {
                "title": "vpnConnectionId",
                "sub_info": [
                    { "key": [ "state" ], "show_key": "State"},
                    { "key": [ "vpnGatewayId" ], "show_key": "Virtual Private Gateway"},
                    { "key": [ "customerGatewayId" ], "show_key": "Customer Gateway"},
                    { "key": [ "type" ], "show_key": "Type"},
                    { "key": [ "routes", "item", "source" ], "show_key": "Routing"}
                ],
                "btns": [
                    { "type": "download_configuration", "name": "Download Configuration" }
                    ],
                "detail_table": [
                    { "key": [ "vgwTelemetry", "item" ], "show_key": "VPN Tunnel", "count_name": "tunnel"},
                    { "key": [ "outsideIpAddress" ], "show_key": "IP Address"},
                    { "key": [ "status" ], "show_key": "Status"},
                    { "key": [ "lastStatusChange" ], "show_key": "Last Changed"},
                    { "key": [ "statusMessage" ], "show_key": "Detail"},
                ]},
            "DescribeVpcs": {
                "title": "vpcId",
                "sub_info": [
                    { "key": [ "state" ], "show_key": "State"},
                    { "key": [ "cidrBlock" ], "show_key": "CIDR"},
                    { "key": [ "instanceTenancy" ], "show_key": "Tenancy"}
                ]}
            "DescribeLoadBalancers": {
                "title": "LoadBalancerName",
                "sub_info":[
                    { "key": [ "state" ], "show_key": "State"},
                    { "key": [ "AvailabilityZones", "member" ], "show_key": "AvailabilityZones"},
                    { "key": [ "CreatedTime" ], "show_key": "CreatedTime"}
                    { "key": [ "DNSName" ], "show_key": "DNSName"}
                    { "key": [ "HealthCheck" ], "show_key": "HealthCheck"}
                    { "key": [ "Instances", 'member' ], "show_key": "Instances"}
                    { "key": [ "ListenerDescriptions", "member", "Listener" ], "show_key": "ListenerDescriptions"}
                    { "key": [ "SecurityGroups"], "show_key": "SecurityGroups"}
                    { "key": [ "Subnets" ], "show_key": "Subnets"}
                    { "key": [ "Instances", 'member' ], "show_key": "Instances"}
                ]}
        }
    }

    #private
    RegionModel = Backbone.Model.extend {

        defaults :

            temp : null
            'region_resource_list'         : null
            'region_resource'              : null
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

                    for ami in result.resolved_data.item

                        region_ami_list[ami.imageId] = ami

                for ins, i in resource_source.DescribeInstances

                    ins.image = region_ami_list[ins.imageId]

                me.reRenderRegionResource()

                null

            elb_model.on 'ELB__DESC_INS_HLT_RETURN', ( result ) ->

                total = result.resolved_data.length

                health = 0

                (health++ if instance.state == "InService") for instance in result.resolved_data

                for elb, i in resource_source.DescribeLoadBalancers

                    if elb.LoadBalancerName == result.param[4]

                        resource_source.DescribeLoadBalancers[i].state = "#{health} of #{total} instances in service"

                me.reRenderRegionResource()

                null

            dhcp_model.on 'VPC_DHCP_DESC_DHCP_OPTS_RETURN', ( result ) ->

                dhcp_set = result.resolved_data.item

                for vpc in resource_source.DescribeVpcs

                    if vpc.dhcpOptionsId == 'default'

                        vpc.dhcp = '{"title": "default", "sub_info" : ["<dt>DhcpOptionsId: </dt><dd>None</dd>"]}'

                    if dhcp_set.constructor == Object

                        if vpc.dhcpOptionsId == dhcp_set.dhcpOptionsId

                            vpc.dhcp = me._genDhcp dhcp_set

                    else

                        for dhcp in dhcp_set

                            if vpc.dhcpOptionsId == dhcp.dhcpOptionsId

                                vpc.dhcp = me._genDhcp dhcp

                me.reRenderRegionResource()

                #console.error me.parseSourceValue 'DescribeDhcpOptions', dhcp, "bubble", null

                null

            customergateway_model.on 'VPC_CGW_DESC_CUST_GWS_RETURN', ( result ) ->

                cgw_set = result.resolved_data.item

                for vpn in resource_source.DescribeVpnConnections

                    if cgw_set.constructor == Object

                        vpn.cgw = me.parseSourceValue 'DescribeCustomerGateways', cgw_set, "bubble", null

                    else

                        for cgw in cgw_set

                            if vpn.customerGatewayId == cgw.customerGatewayId

                                vpn.cgw = me.parseSourceValue 'DescribeCustomerGateways', cgw, "bubble", null

                me.reRenderRegionResource()

            vpngateway_model.on 'VPC_VGW_DESC_VPN_GWS_RETURN', ( result ) ->

                vgw_set = result.resolved_data.item

                for vpn in resource_source.DescribeVpnConnections

                    if vgw_set.constructor == Object

                        vpn.vgw = me.parseSourceValue 'DescribeVpnGateways', vgw_set, "bubble", null

                    else

                        for vgw in vgw_set

                            if vpn.vpnGatewayId == vgw.vpnGatewayId

                                vpn.vgw = me.parseSourceValue 'DescribeVpnGateways', vgw, "bubble", null

                me.reRenderRegionResource()

            null

        #temp
        temp : ->
            me = this
            null

        _genDhcp: (dhcp) ->

            me = this

            popup_key_set.unmanaged_bubble.DescribeDhcpOptions = {}

            popup_key_set.unmanaged_bubble.DescribeDhcpOptions.title = "dhcpOptionsId"

            popup_key_set.unmanaged_bubble.DescribeDhcpOptions.sub_info = []

            sub_info = popup_key_set.unmanaged_bubble.DescribeDhcpOptions.sub_info

            if dhcp.dhcpConfigurationSet.item.constructor == Array

                for item, i in dhcp.dhcpConfigurationSet.item

                    if item.valueSet.item.constructor == Array

                        for it, j in item.valueSet.item

                            sub_info.push { "key": ['dhcpConfigurationSet', 'item', i, 'valueSet', 'item', j, 'value'], "show_key": item.key }

                    else

                        sub_info.push { "key": [ 'dhcpConfigurationSet', 'item', i, 'valueSet', 'item', 'value'], "show_key": item.key }

            else
                item = dhcp.dhcpConfigurationSet.item

                if item.valueSet.item.constructor == Array

                    for it, i in item.valueSet.item

                        sub_info.push { "key": ['dhcpConfigurationSet', 'item', 'valueSet', 'item', j, 'value'], "show_key": item.key }

                else

                    sub_info.push { "key": ['dhcpConfigurationSet', 'item', 'valueSet', 'item', 'value'], "show_key": item.key }

            me.parseSourceValue 'DescribeDhcpOptions', dhcp, "bubble", null

                #sub_info.push { "key": [ dhcp.dhcpConfigurationSet.item.value], "show_key": dhcp.dhcpConfigurationSet.item.key }

        reRenderRegionResource : () ->

            me = this

            me.trigger "REGION_RESOURCE_CHANGED", null

        _set_app_property : ( resource, resources, i, action) ->

            is_managed = false

            if resource.tagSet != undefined and resource.tagSet.item.constructor == Array

                for tag in resource.tagSet.item

                    if tag.key == 'app'

                        is_managed = true

                        resources[action][i].app = tag.value

            if not is_managed

                resources[action][i].app = 'Unmanaged'

            null


        #unmanaged_list
        updateUnmanagedList : ()->

            me = this

            time_stamp = new Date().getTime() / 1000
            unmanaged_list = {}
            unmanaged_list.time_stamp = time_stamp

            unmanaged_list.items = []
            resources_keys       = [ 'DescribeVolumes', 'DescribeLoadBalancers', 'DescribeInstances', 'DescribeVpnConnections', 'DescribeVpcs', 'DescribeAddresses' ]

            console.log resource_source
            _.map resources_keys, ( value ) ->
                cur_attr = resource_source[ value ]

                cur_tag = value

                _.map cur_attr, ( value ) ->
                    if me.hasnotTagId value.tagSet
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

            vpc_model.DescribeAccountAttributes { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  ["supported-platforms"]

            vpc_model.on 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', ( result ) ->

                console.log 'region_VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'

                regionAttrSet = result.resolved_data.accountAttributeSet.item.attributeValueSet.item
                if $.type(regionAttrSet) == "array"
                    vpc_attrs_value = { 'classic' : 'Classic', 'vpc' : 'VPC' }
                else
                    vpc_attrs_value = { 'vpc' : 'VPC' }

                me.set 'vpc_attrs', vpc_attrs_value

                null

            null

        #if an array tagset has tagid
        hasnotTagId : ( tagset )->
            if tagset
                 _.map tagset, ( value ) ->
                    if value.key is "app-id" && value.value
                        false
            true

        #parse bubble value or detail value for unmanagedSource
        parseSourceValue : ( type, value, keys, name )->

            me = this

            keys_to_parse  = null
            value_to_parse = value
            parse_result   = ''
            parse_sub_info = ''
            parse_table    = ''
            parse_btns     = ''

            keys_type = keys
            if popup_key_set[keys]
                keys_to_parse = popup_key_set[keys_type][type]
            else
                keys_type = 'unmanaged_bubble'
                keys_to_parse = popup_key_set[keys_type][type]

            status_keys = keys_to_parse.status
            if status_keys
                state_key = status_keys[0]
                cur_state = value_to_parse[ state_key ]

                _.map status_keys, ( value, key ) ->
                    if cur_state
                        if key > 0
                            cur_state = cur_state[value]
                            null

                if cur_state
                    parse_result += '"status":"' + cur_state + '", '

            if keys_to_parse.title
                if keys is 'unmanaged_bubble' or 'bubble'
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
                            cur_value

                if cur_value
                    if cur_value.constructor == Object
                        console.error me._genBubble cur_value, show_key, true
                        cur_value = me._genBubble cur_value, show_key, true
                    parse_sub_info += ( '"<dt>' + show_key + ': </dt><dd>' + cur_value + '</dd>", ')

                null

            if parse_sub_info
                parse_sub_info = '"sub_info":[' + parse_sub_info
                parse_sub_info = parse_sub_info.substring 0, parse_sub_info.length - 2
                parse_sub_info += ']'

            #parse the table
            if keys_to_parse.detail_table
                parse_table = me.parseTableValue keys_to_parse.detail, value_to_parse
                if parse_table
                    parse_table = '"detail_table":' + parse_table
                    if parse_sub_info
                        parse_sub_info = parse_sub_info + ', ' + parse_table
                    else
                        parse_sub_info = parse_table

            #parse the btns
            if keys_to_parse.btns
                parse_btns  = me.parseBtnValue keys_to_parse.btns, value_to_parse
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

            console.log parse_result

            parse_result

        _genBubble : ( source, title = null, entry = false ) ->

            me = this

            parse_sub_info = ""

            if $.isEmptyObject source

                return ""

            if source.constructor == Object

                for key, value of source

                    if value.constructor == String

                        parse_sub_info += ( '\\"<dt>' + key + ': </dt><dd>' + value + '</dd>\\", ')

                    else
                        parse_sub_info += me._genBubble( value, false)

                if entry
                    bubble_front = '<a href=\\"javascript:void(0)\\" class=\\"bubble table-link\\" data-bubble-template=\\"bubbleRegionResourceInfo\\" data-bubble-data='
                    bubble_end = '>'+title+'</a>'
                    parse_sub_info = " &apos;{\\\"title\\\":" +title + ', \\\"sub_info\\\":[' + parse_sub_info + "]}&apos; "
                    parse_sub_info = bubble_front + parse_sub_info + bubble_end
            if source.constructor == Array

                for value in source

                    if value.constructor == String

                        parse_sub_info += value + "\n"

                    else
                        parse_sub_info += me._genBubble( value, false)

            parse_sub_info

        parseTableValue : ( keyes_set, value_set )->
            null

        parseBtnValue : ( keyes_set, value_set )->
            parse_btns_result = ''
            btn_date         = ''

            _.map keyes_set, ( value ) ->
                btn_date = ''
                if value.type is "download_configuration"
                    dc_data = {
                        vpnConnectionId     : if value_set.vpnConnectionId then value_set.vpnConnectionId else ''
                        vpnGatewayId        : if value_set.vpnConnectionId then value_set.vpnConnectionId else ''
                        customerGatewayId   : if value_set.vpnConnectionId then value_set.vpnConnectionId else ''
                    }
                    dc_filename = if dc_data.vpnConnectionId then dc_data.vpnConnectionId else 'download_configuration'
                    dc_data = MC.template.configurationDownload(dc_data)
                    dc_parse = '{"download":true,"filecontent":"'
                    dc_parse +=  btoa(dc_data)
                    dc_parse += '","filename":"'
                    dc_parse += dc_filename
                    dc_parse +='","btnname":"'
                    dc_parse += value.name
                    dc_parse += '"},'
                    btn_date += dc_parse
                if btn_date
                    btn_date = btn_date.substring 0, btn_date.length - 1
                    parse_btns_result += '['
                    parse_btns_result += btn_date
                    parse_btns_result += ']'

            parse_btns_result

        setResource : ( resources ) ->

            me = this

            lists = {ELB:0, EIP:0, Instance:0, VPC:0, VPN:0, Volume:0}

            lists.Not_Used = { 'EIP' : 0, 'Volume' : 0 }

            # elb
            if resources.DescribeLoadBalancers != null

                lists.ELB = resources.DescribeLoadBalancers.length

                reg = /app-\w{8}/

                for elb, i in resources.DescribeLoadBalancers

                    #me._set_app_property elb, resources, i, 'DescribeLoadBalancers'

                    elb.detail = me.parseSourceValue 'DescribeLoadBalancers', elb, "detail", null

                    if not elb.Instances

                        elb.state = '0 of 0 instances in service'

                    else

                        elb_model.DescribeInstanceHealth { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  elb.LoadBalancerName

                    reg_result = elb.LoadBalancerName.match reg

                    if reg_result then elb.app = reg_result else elb.app = 'Unmanaged'

            # eip
            if resources.DescribeAddresses != null

                for eip, i in resources.DescribeAddresses

                    if $.isEmptyObject eip.instanceId

                        lists.Not_Used.EIP++

                        resources.DescribeAddresses[i].instanceId = 'Not associated'

                    me._set_app_property eip, resources, i, 'DescribeAddresses'

                lists.EIP = resources.DescribeAddresses.length



            # instance
            if resources.DescribeInstances != null

                lists.Instance = resources.DescribeInstances.length

                ami_list = []

                for ins, i in resources.DescribeInstances

                    ami_list.push ins.imageId

                    ins.detail = me.parseSourceValue 'DescribeInstances', ins, "detail", null

                    is_managed = false

                    if ins.tagSet != undefined and ins.tagSet.item.constructor == Array

                        for tag in ins.tagSet.item

                            if tag.key == 'app'

                                is_managed = true

                                resources.DescribeInstances[i].app = tag.value

                            if tag.key == 'name'

                                resources.DescribeInstances[i].host = tag.value

                    if not is_managed

                        resources.DescribeInstances[i].app = 'Unmanaged'

                    if resources.DescribeInstances[i].host == undefined

                        resources.DescribeInstances[i].host = 'Unmanaged'

                # managed instanceid
                manage_instances_id     =   []
                manage_instances_app    =   {}

                for ins in resources.DescribeInstances

                    if ins.app isnt 'Unmanaged'

                        manage_instances_id.push ins.instanceId

                        manage_instances_app[ins.instanceId] = ins.app

            # volume
            lists.Volume = resources.DescribeVolumes.length

            for vol, i in resources.DescribeVolumes

                vol.detail = me.parseSourceValue 'DescribeVolumes', vol, "detail", null

                lists.Not_Used.Volume++ if vol.status == "available"

                me._set_app_property vol, resources, i, 'DescribeVolumes'

                if not vol.attachmentSet
                    vol.attachmentSet = {item:[]}

                    attachment = { device: 'Not-Attached', status: 'Not-Attached'}

                    vol.attachmentSet.item[0] = attachment
                else

                    if vol.attachmentSet.item.instanceId in manage_instances_id

                        resources.DescribeVolumes[i].app = manage_instances_app[vol.attachmentSet.item.instanceId]

            # vpc
            if resources.DescribeVpcs != null

                lists.VPC = resources.DescribeVpcs.length

                for vpc, i in resources.DescribeVpcs

                    me._set_app_property vpc, resources, i, 'DescribeVpcs'

                    vpc.detail = me.parseSourceValue 'DescribeVpcs', vpc, "detail", null

                dhcp_set = []

                for vpc in resources.DescribeVpcs

                    dhcp_set.push vpc.dhcpOptionsId if vpc.dhcpOptionsId not in dhcp_set and vpc.dhcpOptionsId != 'default'

                # get dhcp detail
                if dhcp_set
                    dhcp_model.DescribeDhcpOptions { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  dhcp_set

            # vpn
            if resources.DescribeVpnConnections != null
                lists.VPN = resources.DescribeVpnConnections.length

                for vpn, i in resources.DescribeVpnConnections

                    me._set_app_property vpn, resources, i, 'DescribeVpnConnections'

                    vpn.detail = me.parseSourceValue 'DescribeVpnConnections', vpn, "detail", null

                cgw_set = []

                vgw_set = []

                for vpn in resources.DescribeVpnConnections

                    cgw_set.push vpn.customerGatewayId

                    vgw_set.push vpn.vpnGatewayId

            # get cgw detail
            if cgw_set
                customergateway_model.DescribeCustomerGateways { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  cgw_set

            # get vgw detail
            if vgw_set
                vpngateway_model.DescribeVpnGateways { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  vgw_set

            # ami
            if ami_list
                ami_model.DescribeImages { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  ami_list


            console.error resources
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

            aws_model.on 'AWS_STATUS_RETURN', ( result ) ->

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
    }

    model = new RegionModel()

    return model