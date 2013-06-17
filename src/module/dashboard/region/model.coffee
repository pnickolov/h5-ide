#############################
#  View Mode for dashboard(region)
#############################

define [ 'backbone', 'jquery', 'underscore', 'aws_model', 'ami_model', 'elb_model', 'dhcp_model', 'vpngateway_model', 'customergateway_model', 'vpc_model', 'constant' ], (Backbone, $, _, aws_model, ami_model, elb_model, dhcp_model, vpngateway_model, customergateway_model, vpc_model, constant) ->

    current_region  = null
    resource_source = null
    vpc_attrs_value = null
    unmanaged_list  = null

    update_timestamp = 0

    popup_key_set = {
        "bubble" : {
            "DescribeVolumes": {
                "status": "status",
                "title": "volumeId",
                "sub_info":[
                    { "key": [ "createTime" ], "show_key": "Create-Time"},
                    { "key": [ "availabilityZone" ], "show_key": "AZ"},
                    { "key": [ "attachmentSet", "item", "status" ], "show_key": "Attachment-Status"}
                ]},
            "DescribeInstances": {},
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
            "DescribeVpcs": {}
        },
        "detail" : {
            "DescribeVolumes": {},
            "DescribeInstances": {},
            "DescribeVpnConnections": {},
            "DescribeVpcs": {}
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

                    if dhcp_set.constructor == Object

                        vpc.dhcp = dhcp_set

                    else

                        for dhcp in dhcp_set

                            if vpc.dhcpOptionsId == dhcp.dhcpOptionsId

                                vpc.dhcp = dhcp

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

                        vpn.vgw = vgw_set

                    else

                        for vgw in vgw_set

                            if vpn.vpnGatewayId == vgw.vpnGatewayId

                                vpn.vgw = vgw

                me.reRenderRegionResource()

            null

        #temp
        temp : ->
            me = this
            null

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
                                unmanaged_list.items.push { 'type': "Volume", 'name': (if name then name else value.volumeId), 'status': value.status, 'cost': 0.00, 'data-bubble-data': ( me.parseSourceValue cur_tag, value, "bubble", name ), 'data-modal-data': ( me.parseSourceValue cur_tag, value, "detail" ) }
                            when "DescribeInstances"
                                unmanaged_list.items.push { 'type': "Instance", 'name': (if name then name else value.instanceId), 'status': value.instanceState.name, 'cost': 0.00, 'data-modal-data': '' }
                            when "DescribeVpnConnections"
                                unmanaged_list.items.push { 'type': "VPN", 'name': (if name then name else value.vpnConnectionId), 'status': value.state, 'cost': 0.00, 'data-modal-data': '' }
                            when "DescribeVpcs"
                                unmanaged_list.items.push { 'type': "VPC", 'name': (if name then name else value.vpcId), 'status': value.state, 'cost': 0.00, 'data-modal-data': '' }
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

            vpc_model.once 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', ( result ) ->

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
            keys_to_parse  = null
            value_to_parse = value
            parse_result   = ''
            parse_sub_info = ''

            keys_to_parse = popup_key_set[keys][type]

            if keys_to_parse.status && value_to_parse[ keys_to_parse.status ]
                parse_result += '"status":"' + value_to_parse[ keys_to_parse.status ] + '", '

            if keys_to_parse.title
                if keys is 'bubble'
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

            _.map keys_to_parse.sub_info, ( value ) ->
                key_array = value.key
                show_key  = value.show_key
                cur_key   = key_array[0]
                cur_value = value_to_parse[ cur_key ]

                _.map key_array, ( value, key ) ->
                    if cur_value
                        if key > 0
                            cur_value = cur_value.value
                            cur_value

                if cur_value
                    parse_sub_info += ( '"<dt>' + show_key + '</dt><dd>' + cur_value + '</dd>", ')

                null

            if parse_sub_info
                parse_sub_info = '"sub_info":[' + parse_sub_info
                parse_sub_info = parse_sub_info.substring 0, parse_sub_info.length - 2
                parse_sub_info += ']'

            if parse_result
                parse_result = '{' + parse_result
                if parse_sub_info
                    parse_result += parse_sub_info
                else
                    parse_result = parse_result.substring 0, parse_result.length - 2
                parse_result += '}'

            console.log parse_result

            parse_result


        setResource : ( resources ) ->

            me = this
            
            lists = {}

            lists.Not_Used = { 'EIP' : 0, 'Volume' : 0 }

            # elb
            lists.ELB = resources.DescribeLoadBalancers.length

            reg = /app-\w{8}/

            for elb, i in resources.DescribeLoadBalancers

                #me._set_app_property elb, resources, i, 'DescribeLoadBalancers'

                if $.isEmptyObject elb.Instances

                    elb.state = '0 of 0 instances in service'

                else

                    elb_model.DescribeInstanceHealth { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  elb.LoadBalancerName

                reg_result = elb.LoadBalancerName.match reg

                if reg_result then elb.app = reg_result else elb.app = 'Unmanaged'

            # eip
            lists.EIP = resources.DescribeAddresses.length
            
            for eip, i in resources.DescribeAddresses

                if $.isEmptyObject eip.instanceId

                    lists.Not_Used.EIP++

                    resources.DescribeAddresses[i].instanceId = 'Not associated'

                me._set_app_property eip, resources, i, 'DescribeAddresses'

            # instance
            lists.Instance = resources.DescribeInstances.length

            ami_list = []

            for ins, i in resources.DescribeInstances

                ami_list.push ins.imageId

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

                lists.Not_Used.Volume++ if vol.status == "available"

                me._set_app_property vol, resources, i, 'DescribeVolumes'

                if not vol.attachmentSet.item?.device?

                    vol.attachmentSet.item = {}

                    vol.attachmentSet.item.device = 'Not Attached'

                    vol.attachmentSet.item.status = 'Not Attached'
                else

                    if vol.attachmentSet.item.instanceId in manage_instances_id

                        resources.DescribeVolumes[i].app = manage_instances_app[vol.attachmentSet.item.instanceId]
                        
            # vpc
            lists.VPC = resources.DescribeVpcs.length

            me._set_app_property vpc, resources, i, 'DescribeVpcs' for vpc, i in resources.DescribeVpcs

            dhcp_set = []

            for vpc in resources.DescribeVpcs

                dhcp_set.push vpc.dhcpOptionsId if vpc.dhcpOptionsId not in dhcp_set

            # get dhcp detail
            dhcp_model.DescribeDhcpOptions { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  dhcp_set

            # vpn
            lists.VPN = resources.DescribeVpnConnections.length

            me._set_app_property vpn, resources, i, 'DescribeVpnConnections' for vpn, i in resources.DescribeVpnConnections

            cgw_set = []

            vgw_set = []

            for vpn in resources.DescribeVpnConnections

                cgw_set.push vpn.customerGatewayId

                vgw_set.push vpn.vpnGatewayId

            # get cgw detail

            customergateway_model.DescribeCustomerGateways { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  cgw_set

            # get vgw detail

            vpngateway_model.DescribeVpnGateways { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  vgw_set

            # ami
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
            console.log 'AWS_STATUS_RETURN'

            me = this

            current_region = region

            aws_model.status { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, null
            aws_model.once 'AWS_STATUS_RETURN', ( result ) ->

                console.log 'AWS_STATUS_RETURN'

                console.log result

                me.set 'status_list', ''

                null
    }

    model = new RegionModel()

    return model