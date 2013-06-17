#############################
#  View Mode for dashboard(region)
#############################

define [ 'backbone', 'jquery', 'underscore', 'aws_model', 'ami_model', 'elb_model', 'dhcp_model', 'vpngateway_model', 'customergateway_model', 'constant' ], (Backbone, $, _, aws_model, ami_model, elb_model, dhcp_model, vpngateway_model, customergateway_model, constant) ->

    current_region = null
    resource_source = null

    #private
    RegionModel = Backbone.Model.extend {

        defaults :
            temp : null
            'region_resource_list'         : null
            'region_resource'              : null


        initialize : ->
            me = this

            aws_model.on 'AWS_RESOURCE_RETURN', ( result ) ->

                resource_source = result.resolved_data[current_region]

                me.setResource resource_source

                
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

                null

            customergateway_model.on 'VPC_CGW_DESC_CUST_GWS_RETURN', ( result ) ->

                cgw_set = result.resolved_data.item

                for vpn in resource_source.DescribeVpnConnections

                    if cgw_set.constructor == Object

                        vpn.cgw = cgw_set

                    else

                        for cgw in cgw_set

                            if vpn.customerGatewayId == cgw.customerGatewayId

                                vpn.cgw = cgw

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

    }

    model = new RegionModel()

    return model