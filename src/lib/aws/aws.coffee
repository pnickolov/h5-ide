define [ 'MC', 'constant', 'underscore', 'jquery' ], ( MC, constant, _, $ ) ->

    #private
    getNewName = (compType) ->

        new_name    = ""
        name_prefix = ""
        name_list   = []

        switch compType

            when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
                name_prefix = "host"

            when constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair
                name_prefix = "kp"

            when constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup
                name_prefix = "custom-sg-"

            when constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
                name_prefix = "eip"

            when constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume
                name_prefix = "vol"

            when constant.AWS_RESOURCE_TYPE.AWS_ELB
                name_prefix = "load-balancer-"

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC
                name_prefix = "vpc"

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
                name_prefix = "subnet"

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
                name_prefix = "RT-"

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway
                name_prefix = "customer-gateway-"

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
                name_prefix = "eni"

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions
                name_prefix = "dhcp"

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection
                name_prefix = "vpn"

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
                name_prefix = "acl"

            when constant.AWS_RESOURCE_TYPE.AWS_IAM_ServerCertificate
                name_prefix = "iam"

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway
                name_prefix = "Internet-gateway"

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway
                name_prefix = "VPN-gateway"

            #ASG
            when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
                name_prefix = "asg"

            when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
                name_prefix = "launch-config-"

            when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration
                name_prefix = "asl-nc"

            when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy
                name_prefix = "asl-sp-"

            when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScheduledActions
                name_prefix = "asl-sa-"

            when constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch
                name_prefix = "clw-"

            when constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription
                name_prefix = "sns-sub"

            when constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic
                name_prefix = "sns-topic"


        #get exist name
        _.each MC.canvas_data.component, (compObj) ->

            if compObj.type is compType

                if compObj.serverGroupName
                    name_list.push compObj.serverGroupName
                else
                    name_list.push compObj.name

            null


        #find name
        idx = 1
        while idx <= name_list.length

            if $.inArray( (name_prefix + idx), name_list ) == -1
                #not in name_list
                break

            idx++

        #return new name
        name_prefix + idx


    cacheResource = (resources, region, need_reset) ->

        #cache aws resource data to MC.data.reosurce_list

        if !resources or !region or !MC.data.resource_list
            console.log 'cacheResource failed'
            return null

        if need_reset
            MC.data.resource_list[region] = {}


        try

            #vpc
            if resources.DescribeVpcs
                _.map resources.DescribeVpcs, ( res, i ) ->
                    MC.data.resource_list[region][res.vpcId] = res
                    null

            #instance
            if resources.DescribeInstances
                _.map resources.DescribeInstances, ( res, i ) ->
                    MC.data.resource_list[region][res.instanceId] = res
                    null

            #volume
            if resources.DescribeVolumes
                _.map resources.DescribeVolumes, ( res, i ) ->
                    MC.data.resource_list[region][res.volumeId] = res
                    null

            #eip
            if resources.DescribeAddresses
                _.map resources.DescribeAddresses, ( res, i ) ->
                    MC.data.resource_list[region][res.publicIp] = res
                    null

            #elb
            if resources.DescribeLoadBalancers
                _.map resources.DescribeLoadBalancers, ( res, i ) ->
                    MC.data.resource_list[region][res.LoadBalancerName] = res
                    null

            #vpn
            if resources.DescribeVpnConnections
                _.map resources.DescribeVpnConnections, ( res, i ) ->
                    MC.data.resource_list[region][res.vpnConnectionId] = res
                    null

            #kp
            if resources.DescribeKeyPairs
                _.map resources.DescribeKeyPairs, ( res, i ) ->
                    MC.data.resource_list[region][res.keyFingerprint] = res
                    null

            #sg
            if resources.DescribeSecurityGroups
                _.map resources.DescribeSecurityGroups, ( res, i ) ->
                    MC.data.resource_list[region][res.groupId] = res
                    null

            #dhcp
            if resources.DescribeDhcpOptions
                _.map resources.DescribeDhcpOptions, ( res, i ) ->
                    MC.data.resource_list[region][res.dhcpOptionsId] = res
                    null

            #subnet
            if resources.DescribeSubnets
                _.map resources.DescribeSubnets, ( res, i ) ->
                    MC.data.resource_list[region][res.subnetId] = res
                    null

            #routetable
            if resources.DescribeRouteTables
                _.map resources.DescribeRouteTables, ( res, i ) ->
                    MC.data.resource_list[region][res.routeTableId] = res
                    null

            #acl
            if resources.DescribeNetworkAcls
                _.map resources.DescribeNetworkAcls, ( res, i ) ->
                    MC.data.resource_list[region][res.networkAclId] = res
                    null

            #eni
            if resources.DescribeNetworkInterfaces
                _.map resources.DescribeNetworkInterfaces , ( res, i ) ->
                    MC.data.resource_list[region][res.networkInterfaceId] = res
                    null

            #igw
            if resources.DescribeInternetGateways
                _.map resources.DescribeInternetGateways, ( res, i ) ->
                    MC.data.resource_list[region][res.internetGatewayId] = res
                    null

            #vgw
            if resources.DescribeVpnGateways
                _.map resources.DescribeVpnGateways, ( res, i ) ->
                    MC.data.resource_list[region][res.vpnGatewayId] = res
                    null

            #cgw
            if resources.DescribeCustomerGateways
                _.map resources.DescribeCustomerGateways, ( res, i ) ->
                    MC.data.resource_list[region][res.customerGatewayId] = res
                    null

            #ami
            if resources.DescribeImages
                _.map resources.DescribeImages, ( res, i ) ->
                    try
                        if !res.osType
                            res = $.extend true, {}, res
                            res.osType = MC.aws.ami.getOSType res

                        res.osFamily = MC.aws.aws.getOSFamily(res.osType)

                        MC.data.dict_ami[res.imageId] = res
                        MC.data.resource_list[region][res.imageId] = res

                    catch e
                        console.log "[cacheResource:DescribeImages]error: " + res.imageId

                    null


            ########################

            #asg
            if resources.DescribeAutoScalingGroups
                _.map resources.DescribeAutoScalingGroups, ( res, i ) ->
                    MC.data.resource_list[region][res.AutoScalingGroupARN] = res
                    null

            #asl lc
            if resources.DescribeLaunchConfigurations
                _.map resources.DescribeLaunchConfigurations, ( res, i ) ->
                    MC.data.resource_list[region][res.LaunchConfigurationARN] = res
                    null

            #asl nc
            if resources.DescribeNotificationConfigurations

                #init
                if !MC.data.resource_list[region].NotificationConfigurations
                    MC.data.resource_list[region].NotificationConfigurations = []

                _.map resources.DescribeNotificationConfigurations, ( res, i ) ->

                    #found by protocol + endpoint + topicarn
                    found = null
                    _.each MC.data.resource_list[region].NotificationConfigurations, ( item ) ->
                        if item.AutoScalingGroupName is res.AutoScalingGroupName and item.NotificationType is res.NotificationType and item.TopicARN is res.TopicARN
                            found = item
                            return false
                        null

                    if !found
                        MC.data.resource_list[region].NotificationConfigurations.push res
                    null


            #asl sp
            if resources.DescribePolicies
                _.map resources.DescribePolicies, ( res, i ) ->
                    MC.data.resource_list[region][res.PolicyARN] = res
                    null

            #asl sa
            if resources.DescribeScheduledActions
                _.map resources.DescribeScheduledActions, ( res, i ) ->
                    MC.data.resource_list[region][res.ScheduledActionARN] = res
                    null

            #clw
            if resources.DescribeAlarms
                _.map resources.DescribeAlarms, ( res, i ) ->
                    MC.data.resource_list[region][res.AlarmArn] = res
                    null

            #sns sub
            if resources.ListSubscriptions

                #init
                if !MC.data.resource_list[region].Subscriptions
                    MC.data.resource_list[region].Subscriptions = []

                _.map resources.ListSubscriptions, ( res, i ) ->

                    #found by protocol + endpoint + topicarn
                    found = null
                    _.each MC.data.resource_list[region].Subscriptions, ( item ) ->
                        if item.Protocol is res.Protocol and item.Endpoint is res.Endpoint and item.TopicArn is res.TopicArn
                            found = item
                            return false
                        null

                    if found
                        #only update SubscriptionArn
                        found.SubscriptionArn = res.SubscriptionArn
                    else
                        MC.data.resource_list[region].Subscriptions.push res
                    null

            #sns topic
            if resources.ListTopics
                _.map resources.ListTopics, ( res, i ) ->
                    MC.data.resource_list[region][res.TopicArn] = res
                    null


            #asl instance
            if resources.DescribeAutoScalingInstances
                _.map resources.DescribeAutoScalingInstances, ( res, i ) ->
                    MC.data.resource_list[region][res.AutoScalingGroupName + ':' + res.InstanceId] = res
                    null


            #asl activities
            if resources.DescribeScalingActivities
                _.map resources.DescribeScalingActivities, ( res, i ) ->
                    MC.data.resource_list[region][res.ActivityId] = res
                    null

            #instance health(elb)
            if resources.DescribeInstanceHealth

                if !MC.data.resource_list[region].instance_health
                    MC.data.resource_list[region].instance_health = {}

                _.map resources.DescribeInstanceHealth, ( res, i ) ->
                    MC.data.resource_list[region].instance_health[res.InstanceId] = res
                    null

        catch error

            console.info error

        null


    checkIsRepeatName = (compUID, newName) ->

        originCompObj = MC.canvas_data.component[compUID]
        originCompUID = originCompObj.uid
        originCompType = originCompObj.type

        not _.some MC.canvas_data.component, (compObj) ->
            compUID = compObj.uid
            compType = compObj.type
            compName = compObj.name
            if originCompType is compType and originCompUID isnt compUID and newName is compName
                return true


    checkStackName = ( stackId, newName ) ->
        stackArray = _.flatten _.values MC.data.stack_list

        not _.some stackArray, ( stack ) ->
            stack.id isnt stackId and stack.name is newName

    checkAppName = ( name ) ->
        appArray = _.flatten _.values MC.data.app_list
        not _.contains appArray, name

    disabledAllOperabilityArea = (enabled) ->

        if enabled
            $('#resource-panel').append('<div class="disabled-event-layout"></div>')
            $('#canvas').append('<div class="disabled-event-layout"></div>')
            $('#tabbar-wrapper').append('<div class="disabled-event-layout"></div>')
        else
            $('.disabled-event-layout').remove()

    getDuplicateName = (stack_name) ->

        copy_name   = stack_name + "-copy-"
        name_list   = []
        stacks      = _.flatten _.values MC.data.stack_list

        name_list.push i.name for i in stacks when i.name.indexOf(copy_name) == 0

        idx = 1
        while idx <= name_list.length
            if $.inArray( (copy_name + idx), name_list ) == -1
                break
            idx++

        copy_name + idx

    getCost = (data) ->
        me = this

        cost_list = []
        total_fee = 0

        region = data.region
        feeMap = MC.data.config[region]

        is_app = if data.id.indexOf('app-') == 0 then true else false

        #no config data load
        if not ( feeMap and 'price' of feeMap )
            return { 'cost_list' : cost_list, 'total_fee' : total_fee }

        currency = if 'currency' of feeMap.price then feeMap.price.currency else 'USD'

        for uid of data.component
            item = data.component[uid]
            name = item.name
            type = item.type

            # instance
            if item.type is 'AWS.EC2.Instance'
                size = item.resource.InstanceType
                number = if item.number then item.number else 1

                # osType and osFamily
                osType = osFamily = ''
                try
                    osType = data.layout.component.node[item.uid].osType
                catch e
                    if not osType
                        continue

                osFamily = data.layout.component.node[item.uid].osFamily
                if not osFamily
                    osFamily = me.getOSFamily(osType)

                if size and osFamily and 'instance' of feeMap.price
                    size_list = size.split('.')
                    unit = feeMap.price['instance']['unit']
                    fee = feeMap.price['instance'][size_list[0]][size_list[1]]['onDemand'][osFamily][currency]

                    if fee and unit
                        cost_list.push { 'resource' : name, 'size' : size, 'fee' : fee , 'unit' : (if unit is 'perhr' then '/hr' else '/mo'), 'count' : number }

                        # detail monitor
                        if item.resource.Monitoring is 'enabled'
                            cw_fee = i.ec2Monitoring[currency] for i in feeMap.price.cloudwatch.types when 'ec2Monitoring' of i
                            cost_list.push { 'resource' : name, 'type' : 'CloudWatch', 'fee' : cw_fee, 'unit' : '/mo', 'count' : 1 }

                #attached volume
                vols = item.resource.BlockDeviceMapping
                if vols and 'price' of feeMap and 'ebs' of feeMap.price
                    for vol_uid in vols
                        volume = data.component[vol_uid.split('#')[1]]
                        if volume.resource.VolumeType is 'standard'
                            vol_lst = i.ebsVols for i in feeMap.price.ebs.types when 'ebsVols' of i
                        else
                            vol_lst = i.ebsPIOPSVols for i in feeMap.price.ebs.types when 'ebsPIOPSVols' of i

                        vol_fee = i[currency] for i in vol_lst when i.unit is 'perGBmoProvStorage'

                        cost_list.push { 'resource' : name + ' - ' + volume.name, 'size' :  volume.resource.Size + 'G', 'fee' : vol_fee, 'unit' : '/GB/mo', 'count' : parseInt(volume.resource.Size) }

            # elb
            else if item.type is 'AWS.ELB'
                if 'elb' of feeMap.price and 'types' of feeMap.price.elb
                    elb_fee = i[currency] for i in feeMap.price.elb.types when i.unit is 'perELBHour'

                    cost_list.push { 'type' : type, 'resource' : name, 'fee' : elb_fee, 'unit' : '/hr', 'count' : 1 }

            # asg
            else if item.type is 'AWS.AutoScaling.Group'
                cap = if item.resource.DesiredCapacity and is_app then item.resource.DesiredCapacity else item.resource.MinSize

                config_uid = MC.extractID item.resource.LaunchConfigurationName
                config = MC.canvas_data.component[config_uid]

                if config

                    asg_fee = 0
                    size    = config.resource.InstanceType

                    # osType and osFamily
                    osType = osFamily = ''
                    try
                        osType = data.layout.component.node[config_uid].osType
                    catch e
                        if not osType
                            continue

                    osFamily = data.layout.component.node[config_uid].osFamily
                    if not osFamily
                        osFamily = me.getOSFamily(osType)

                    if size and osFamily and 'instance' of feeMap.price
                        size_list = size.split('.')
                        unit = feeMap.price['instance']['unit']
                        fee = feeMap.price['instance'][size_list[0]][size_list[1]]['onDemand'][osFamily][currency]

                        if not fee or not unit
                            continue
                        if unit is 'perhr'
                            asg_fee += fee * 24 * 30 * cap
                        else
                            asg_fee += fee

                    if config.resource.BlockDeviceMapping
                        for block in config.resource.BlockDeviceMapping
                            vol_lst = i.ebsVols for i in feeMap.price.ebs.types when 'ebsVols' of i
                            vol_fee = i[currency] for i in vol_lst when i.unit is 'perGBmoProvStorage'
                            asg_fee += block.Ebs.VolumeSize * vol_fee

                    if asg_fee > 0
                        cost_list.push {'resource' : name, 'size' : cap, 'fee' : asg_fee.toFixed(3), 'unit' : '/mo'}

                    ## detail monitor
                    # if config.resource.InstanceMonitoring is 'enabled'
                    #     fee = 3.50
                    #     cost_list.push { 'resource' : name, 'type' : 'Detailed Monitoring', 'fee' : fee, 'unit' : '/mo' }

            # cloudwatch to asg
            else if item.type is 'AWS.CloudWatch.CloudWatch'
                period = parseInt(item.resource.Period, 10)
                if period and period <= 300 and item.resource.Namespace == "AWS/AutoScaling"
                    cw_fee =  i.ec2Monitoring[currency] for i in feeMap.price.cloudwatch.types when 'ec2Monitoring' of i
                    # get capacity of the asg
                    size = 1
                    asg_uid = if item.resource.Dimensions.length>0 then item.resource.Dimensions[0].value
                    if asg_uid
                        asg = data.component[asg_uid.split('.')[0].substr(1)]
                        size = if asg.resource.DesiredCapacity and is_app then asg.resource.DesiredCapacity else asg.resource.MinSize
                        cost_list.push {'resource' : name, 'type' : 'CloudWatch', 'count' : size, 'fee' : cw_fee/7, 'unit' : '/mo'}

            null

        # compute total fee
        last_cost_list = []
        for c in cost_list
            fee = c.fee
            size = if 'count' of c then c.count else c.size
            unit = if c.unit and c.unit == '/hr' then 24*30 else 1

            com_fee = fee * unit * size
            # invalid check
            if isNaN(com_fee)
                continue

            total_fee += com_fee
            last_cost_list.push c

        # sort with type
        last_cost_list.sort (a, b) ->
            if a.type > b.type
                return 1
            else if a.type < b.type
                return -1
            else
                return if a.resource.toLowerCase() >= b.resource.toLowerCase() then 1 else -1

        return { 'cost_list' : last_cost_list, 'total_fee' : total_fee.toFixed(2) }

    checkDefaultVPC = () ->

        currentRegion = MC.canvas_data.region
        accountData = MC.data.account_attribute[currentRegion]
        if accountData.support_platform is 'VPC' and MC.canvas_data.platform is 'default-vpc'
            return accountData.default_vpc
        else
            return false

    checkResource = ( uid ) ->
        if uid
            components =
                uid : MC.canvas_data.component[uid]
        else
            components = MC.canva_data.component

        res = {}
        res_type = constant.AWS_RESOURCE_TYPE
        data     = MC.data.resource_list[ MC.canvas_data.region ]
        for c_uid, comp of components
            r = true
            switch comp.type
                when res_type.AWS_VPC_NetworkAcl
                    r = data[ comp.resource.NetworkAclId ]
                when res_type.AWS_AutoScaling_Group
                    r = data[ comp.resource.AutoScalingGroupARN ]
                when res_type.AWS_VPC_CustomerGateway
                    r = data[ comp.resource.CustomerGatewayId ]
                when res_type.AWS_ELB
                    r = data[ comp.resource.LoadBalancerName ]
                when res_type.AWS_VPC_NetworkInterface
                    r = data[ comp.resource.NetworkInterfaceId ]
                when res_type.AWS_EC2_Instance
                    r = data[ comp.resource.InstanceId ]
                when res_type.AWS_AutoScaling_LaunchConfiguration
                    r = data[ comp.resource.LaunchConfigurationARN ]
                when res_type.AWS_VPC_RouteTable
                    r = data[ comp.resource.RouteTableId ]
                when res_type.AWS_VPC_Subnet
                    r = data[ comp.resource.SubnetId ]
                when res_type.AWS_EBS_Volume
                    r = data[ comp.resource.VolumeId ]
                when res_type.AWS_VPC_VPC
                    r = data[ comp.resource.VpcId ]

            res[ c_uid ] = if r then true else false

        if uid then res[uid] else res
    regionNameMap =
        'us-west-1': [ 'US West', 'N. California' ]
        'us-west-2': [ 'US West', 'Oregon' ]
        'us-east-1': [ 'US East', 'Virginia' ]
        'eu-west-1': [ 'EU West', 'Ireland' ]
        'ap-southeast-1': [ 'Asia Pacific', 'Singapore' ]
        'ap-southeast-2': [ 'Asia Pacific', 'Sydney' ]
        'ap-northeast-1': [ 'Asia Pacific', 'Tokyo' ]
        'sa-east-1': [ 'South America', 'Sao Paulo' ]

    getRegionName = ( region, option ) ->
        if region of regionNameMap
            if option is 'fullname'
                return "#{regionNameMap[ region ][ 0 ]} - #{regionNameMap[ region ][ 1 ]}"
            regionNameMap[ region ][ 1 ]
        else
            null

    isExistResourceInApp = ( compUID ) ->

        compObj = MC.canvas_data.component[compUID]
        if !compObj then return true

        compType = compObj.type

        compRes = compObj.resource

        resourceId = null

        switch compType

            when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
                resourceId = compRes.InstanceId

            when constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair
                resourceId = compRes.KeyFingerprint

            when constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup
                resourceId = compRes.GroupId

            when constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
                resourceId = compRes.PublicIp

            when constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume
                resourceId = compRes.VolumeId

            when constant.AWS_RESOURCE_TYPE.AWS_ELB
                resourceId = compRes.LoadBalancerName

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC
                resourceId = compRes.VpcId

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
                resourceId = compRes.SubnetId

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
                resourceId = compRes.RouteTableId

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway
                resourceId = compRes.CustomerGatewayId

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
                resourceId = compRes.NetworkInterfaceId

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions
                resourceId = compRes.DhcpOptionsId

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection
                resourceId = compRes.VpnConnectionId

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
                resourceId = compRes.NetworkAclId

            when constant.AWS_RESOURCE_TYPE.AWS_IAM_ServerCertificate
                resourceId = compRes.ServerCertificateMetadata.ServerCertificateId

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway
                resourceId = compRes.InternetGatewayId

            when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway
                resourceId = compRes.VpnGatewayId

            # In stopped app, ASG doesn't have AWS Resource
            # when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
                # resourceId = compRes.AutoScalingGroupARN

            when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
                resourceId = compRes.LaunchConfigurationARN

            when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration
                resourceId = "asl-nc"

            when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy
                resourceId = compRes.PolicyARN

            when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScheduledActions
                resourceId = compRes.ScheduledActionARN

            when constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch
                resourceId = compRes.AlarmArn

            when constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription
                resourceId = "sns-sub"

            when constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic
                resourceId = compRes.TopicArn

        region = MC.canvas_data.region

        if !resourceId or (resourceId and MC.data.resource_list[region][resourceId])
            return true
        else
            return false

    getChanges = (data, ori_data) ->
        me = this

        changes = {'remain':[], 'remove':[]}

        # first check change
        new_str = JSON.stringify(data)
        ori_str = JSON.stringify(ori_data)
        if new_str != ori_str
            isChanged = true

            for uid of ori_data.component
                item = ori_data.component[uid]
                if item.index != 0
                    continue

                # only instance
                if item.type is 'AWS.EC2.Instance'
                    if uid of data.component    # remain
                        n_item = data.component[uid]
                        if item.number > 1
                            index = 0
                            for inst_uid in ori_data.layout.component.node[uid].instanceList
                                index = index + 1
                                if item.resource.InstanceType isnt n_item.resource.InstanceType and index <= n_item.number
                                    changes['remain'].push {'name':ori_data.component[inst_uid].name, 'instance_id':ori_data.component[inst_uid].resource.InstanceId}

                                if index > n_item.number
                                    changes['remove'].push {'name':ori_data.component[inst_uid].name, 'instance_id':ori_data.component[inst_uid].resource.InstanceId}

                        else
                            if item.resource.InstanceType isnt n_item.resource.InstanceType
                                changes['remain'].push {'name':ori_data.component[uid].name, 'instance_id':ori_data.component[uid].resource.InstanceId}

                    else
                        if item.number > 1
                            for inst_uid in ori_data.layout.component.node[uid].instanceList
                                changes['remove'].push {'name':ori_data.component[inst_uid].name, 'instance_id':ori_data.component[inst_uid].resource.InstanceId}
                        else
                            changes['remove'].push {'name':item.name, 'instance_id':item.resource.InstanceId}

        {'isChanged':isChanged, 'changes':changes}

    getOSFamily = (osType) ->
        me = this

        osFamily = ''

        if osType
            if constant.OS_TYPE_MAPPING[osType]
                osFamily = constant.OS_TYPE_MAPPING[osType]
            else if osType in constant.LINUX
                osFamily = 'linux'
            else if osType in constant.WINDOWS
                osFamily = 'mswin'

        osFamily

    #public
    getNewName                  : getNewName
    cacheResource               : cacheResource
    checkIsRepeatName           : checkIsRepeatName
    checkStackName              : checkStackName
    checkAppName                : checkAppName
    getDuplicateName            : getDuplicateName
    disabledAllOperabilityArea  : disabledAllOperabilityArea
    getCost                     : getCost
    checkDefaultVPC             : checkDefaultVPC
    checkResource               : checkResource
    getRegionName               : getRegionName
    isExistResourceInApp        : isExistResourceInApp
    getChanges                  : getChanges
    getOSFamily                 : getOSFamily
