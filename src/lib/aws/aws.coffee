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


    cacheResource = (resources, region) ->

        #cache aws resource data to MC.data.reosurce_list

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
                if !MC.data.dict_ami[res.imageId]
                    MC.data.dict_ami[res.imageId] = res
                #MC.data.resource_list[region][res.imageId] = res
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

        #no config data load
        if not ( feeMap and feeMap.ami and feeMap.price )
            return { 'cost_list' : cost_list, 'total_fee' : total_fee }

        _.map data.component, (item) ->
            uid = item.uid
            name = item.name
            type = item.type

            # instance
            if item.type is 'AWS.EC2.Instance'
                size = item.resource.InstanceType
                imageId = item.resource.ImageId

                number = if item.number then item.number else 1



                if 'ami' of feeMap

                    fee = unit = null

                    if imageId of feeMap.ami    #quickstart ami

                        ami = v for k,v of feeMap.ami when v.imageId == imageId

                        if feeMap.ami[imageId].osType is 'win'
                            os = 'windows'
                        else
                            os = 'linux-other'

                        size_list = size.split('.')
                        fee  = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].fee
                        unit = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].unit

                    else if imageId of MC.data.dict_ami    # community ami

                        com = MC.data.dict_ami[imageId]

                        if com.osType is 'win'
                            os = 'windows'
                        else
                            os = 'linux-other'

                        size_list = size.split('.')
                        fee  = feeMap.price['instance'][os][size_list[0]][size_list[1]].fee
                        unit = feeMap.price['instance'][os][size_list[0]][size_list[1]].unit

                    if fee and unit
                        cost_list.push { 'resource' : name, 'size' : size, 'fee' : fee + (if unit is 'hour' then '/hr' else '/mo') }

                        total_fee += fee * 24 * 30 * number

                        ## detail monitor
                        if item.resource.Monitoring is 'enabled'

                            fee = 3.50
                            cost_list.push { 'resource' : name, 'type' : 'Detailed Monitoring', 'fee' : fee + '/mo' }
                            total_fee += fee

                ##attached volume
                vols = item.resource.BlockDeviceMapping
                if vols and 'price' of feeMap and 'ebs' of feeMap.price
                    for vol_uid in vols
                        volume = data.component[vol_uid.split('#')[1]]
                        if volume.resource.VolumeType is 'standard'
                            vol_fee = i for i in feeMap.price.ebs.ebsVols when i.unit is 'perGBmoProvStorage'
                        else
                            vol_fee = i for i in feeMap.price.ebs.ebsPIOPSVols when i.unit is 'perGBmoProvStorage'

                        cost_list.push { 'resource' : name + ' - ' + volume.name, 'size' :  volume.resource.Size + 'G', 'fee' : vol_fee.fee + '/GB/mo' }

                        total_fee += parseFloat(vol_fee.fee * volume.resource.Size * number)

            # elb
            else if item.type is 'AWS.ELB'
                if 'price' of feeMap and 'elb' of feeMap.price
                    elb = i for i in feeMap.price.elb when i.unit is 'perELBHour'

                    cost_list.push { 'type' : type, 'resource' : name, 'fee' : elb.fee + '/hr' }

                    total_fee += elb.fee * 24 * 30

            # volume
            # else if item.type is 'AWS.EC2.EBS.Volume'
            #     if 'price' of feeMap and 'ebs' of feeMap.price
            #         if item.resource.VolumeType is 'standard'
            #             vol = i for i in feeMap.price.ebs.ebsVols when i.unit is 'perGBmoProvStorage'
            #         else
            #             vol = i for i in feeMap.price.ebs.ebsPIOPSVols when i.unit is 'perGBmoProvStorage'

            #         # get attached instanc name
            #         instance_uid    = item.resource.AttachmentSet.InstanceId.split('@')[1].split('.')[0]
            #         instance_name   = MC.canvas_data.component[instance_uid].name

            #         cost_list.push { 'resource' : instance_name + ' - ' + name, 'size' :  item.resource.Size + 'G', 'fee' : vol.fee + '/GB/mo' }

            #         total_fee += parseFloat(vol.fee * item.resource.Size)

            # asg
            else if item.type is 'AWS.AutoScaling.Group'
                cap = if item.resource.DesiredCapacity then item.resource.DesiredCapacity else item.resource.MinSize

                config_uid = item.resource.LaunchConfigurationName.split('@')[1].split('.')[0]
                config = MC.canvas_data.component[config_uid]

                if config

                    asg_price = 0

                    imageId = config.resource.ImageId
                    size    = config.resource.InstanceType

                    ami = v for k,v of feeMap.ami when v.imageId == imageId

                    if 'ami' of feeMap and imageId of feeMap.ami

                        if feeMap.ami[imageId].osType is 'win'
                            os = 'windows'
                        else
                            os = 'linux-other'

                        size_list = size.split('.')
                        fee = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].fee
                        unit = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].unit

                        if unit is 'hour'
                            asg_price += fee * 24 * 30
                        else
                            asg_price += fee

                    if config.resource.BlockDeviceMapping
                        for block in config.resource.BlockDeviceMapping
                            vol = i for i in feeMap.price.ebs.ebsVols when i.unit is 'perGBmoProvStorage'
                            asg_price += block.Ebs.VolumeSize * vol.fee

                    if asg_price > 0

                        cost_list.push {'resource' : name, 'size' : cap, 'fee' : asg_price.toFixed(3) + '/mo'}
                        total_fee += asg_price * cap

                    ## detail monitor
                    if config.resource.InstanceMonitoring is 'enabled'

                        fee = 3.50
                        cost_list.push { 'resource' : name, 'type' : 'Detailed Monitoring', 'fee' : fee + '/mo' }
                        total_fee += fee

            ## alarm
            else if item.type is 'AWS.CloudWatch.CloudWatch'
                period = parseInt(item.resource.Period, 10)
                if period and period <= 300
                    fee = 0.10
                    cost_list.push {'resource' : name, 'size' : '', 'fee' : fee + '/mo'}
                    total_fee += fee

            null

        # sort with type
        cost_list.sort (a, b) ->
            return if a.type <= b.type then 1 else -1

        return { 'cost_list' : cost_list, 'total_fee' : total_fee.toFixed(2) }

    checkDefaultVPC = () ->

        currentRegion = MC.canvas_data.region
        accountData = MC.data.account_attribute[currentRegion]
        if accountData.support_platform is 'VPC'
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
