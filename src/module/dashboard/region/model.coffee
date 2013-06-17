#############################
#  View Mode for dashboard(region)
#############################

define [ 'backbone', 'jquery', 'underscore', 'aws_model', 'ami_model', 'elb_model','constant' ], (Backbone, $, _, aws_model, ami_model, elb_model, constant) ->

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


            null
            
        #temp
        temp : ->
            me = this
            null


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

            for elb, i in resources.DescribeLoadBalancers

                me._set_app_property elb, resources, i, 'DescribeLoadBalancers'

                if $.isEmptyObject elb.Instances

                    elb.state = '0 of 0 instances in service'

                else

                    elb_model.DescribeInstanceHealth { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  elb.LoadBalancerName

 




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

            # vpn
            lists.VPN = resources.DescribeVpnConnections.length

            me._set_app_property vpn, resources, i, 'DescribeVpnConnections' for vpn, i in resources.DescribeVpnConnections


            # ami
            ami_model.DescribeImages { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  ami_list

            ami_model.on 'EC2_AMI_DESC_IMAGES_RETURN', ( result ) ->

                region_ami_list = {}

                if result.resolved_data.item.constructor == Array

                    for ami in result.resolved_data.item

                        region_ami_list[ami.imageId] = ami
                
                for ins, i in resources.DescribeInstances

                    ins.image = region_ami_list[ins.imageId]

                me.set 'region_resource', resources

                null

            elb_model.on 'ELB__DESC_INS_HLT_RETURN', ( result ) ->

                console.error result

                total = result.resolved_data.length

                health = 0

                (health++ if instance.state == "InService") for instance in result.resolved_data

                for elb, i in resources.DescribeLoadBalancers

                    if elb.LoadBalancerName == result.param[4]

                        resources.DescribeLoadBalancers[i].state = "#{health} of #{total} instances in service"

                console.error resources
                me.set 'region_resource', resources

                null
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