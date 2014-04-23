define [ 'MC', 'constant', 'underscore', 'jquery', 'Design' ], ( MC, constant, _, $, Design ) ->

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

            # merge elb cache
            elbResMap = {}

            #elb
            if resources.DescribeLoadBalancers
                _.map resources.DescribeLoadBalancers, ( res, i ) ->
                    if not elbResMap[res.LoadBalancerName]
                        elbResMap[res.LoadBalancerName] = {}
                    elbResMap[res.LoadBalancerName] = _.extend(elbResMap[res.LoadBalancerName], res)
                    null

            #elb attributes (disable these code because it's already embed in ELB)
            if resources.DescribeLoadBalancerAttributes
                _.map resources.DescribeLoadBalancerAttributes, ( res, i ) ->
                    if not elbResMap[res.LoadBalancerName]
                        elbResMap[res.LoadBalancerName] = {}
                    elbResMap[res.LoadBalancerName] = _.extend(elbResMap[res.LoadBalancerName], res)
                    null

            #instance health(elb)
            if resources.DescribeInstanceHealth
                _.map resources.DescribeInstanceHealth, ( res, i ) ->
                    if not elbResMap[res.LoadBalancerName]
                        elbResMap[res.LoadBalancerName] = {}
                    elbResMap[res.LoadBalancerName] = _.extend(elbResMap[res.LoadBalancerName], {
                        InstanceState: res
                    })
                    null

            _.map elbResMap, (res) ->
                MC.data.resource_list[region][res.DNSName] = res

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

                        if not res.osFamily
                            res.osFamily = MC.aws.aws.getOSFamily(res.osType, res)

                        convertBlockDeviceMapping res
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

    getDuplicateName = (stack_name) ->

        if not stack_name
            stack_name = "untitled"

        idx = 0
        reg_name = /.*-\d+$/
        if reg_name.test stack_name
            #xxx-n
            prefix = stack_name.substr(0,stack_name.lastIndexOf("-"))
            idx = Number(stack_name.substr(stack_name.lastIndexOf("-") + 1))
            copy_name = prefix
        else
            if stack_name.charAt(name.length-1) is "-"
                #xxxx-
                copy_name = stack_name.substr(0,stack_name.length-1)
            else
                copy_name = stack_name

        name_list   = []
        stacks      = _.flatten _.values MC.data.stack_list

        name_list.push i.name for i in stacks when i.name.indexOf(copy_name) == 0

        idx++
        while idx <= name_list.length
            if $.inArray( (copy_name + "-" + idx), name_list ) == -1
                break
            idx++

        copy_name + "-" + idx

    getOSFamily = (osType, ami) ->
        me = this

        osFamily = 'linux'

        if osType
            if constant.OS_TYPE_MAPPING[osType]
                osFamily = constant.OS_TYPE_MAPPING[osType]

            if osType in constant.WINDOWS
                osFamily = 'mswin'

                try
                    if ami
                        sql_web_pattern = /sql.*?web.*?/
                        sql_standerd_pattern = /sql.*?standard.*?/

                        if ( 'name' of ami and ami.name.toLowerCase().match(sql_web_pattern) ) or ( 'description' of ami and ami.description.toLowerCase().match(sql_web_pattern) ) or ( 'imageLocation' of ami and ami.imageLocation.toLowerCase().match(sql_web_pattern) )
                            osFamily = 'mswinSQLWeb'

                        else if ( 'name' of ami and ami.name.toLowerCase().match(sql_standerd_pattern) ) or ( 'description' of ami and ami.description.toLowerCase().match(sql_standerd_pattern) ) or ( 'imageLocation' of ami and ami.imageLocation.toLowerCase().match(sql_standerd_pattern) )
                            osFamily = 'mswinSQL'

                catch error
                    console.info error

        osFamily

    collectReference = ( canvas_component ) ->

        key = {}

        #collect reference
        for uid, comp of canvas_component

            if constant.AWS_RESOURCE_KEY[comp.type]

                key[comp.resource[constant.AWS_RESOURCE_KEY[comp.type]]] = MC.aws.aws.genResRef(uid, "resource.#{constant.AWS_RESOURCE_KEY[comp.type]}")

                if comp.type is "AWS.EC2.KeyPair"

                    key[comp.resource.KeyName + '-keypair'] = MC.aws.aws.genResRef(uid, 'resource.KeyName')

                if comp.type is "AWS.AutoScaling.Group"

                    key[comp.resource.AutoScalingGroupName + '-asg'] = MC.aws.aws.genResRef(uid, 'resource.AutoScalingGroupName')

                if comp.type is "AWS.AutoScaling.LaunchConfiguration"

                    key[comp.resource.LaunchConfigurationName + '-lc'] = MC.aws.aws.genResRef(uid, 'resource.LaunchConfigurationName')

                if comp.type is 'AWS.VPC.NetworkInterface'

                    for idx, ipset of comp.resource.PrivateIpAddressSet

                        key[ipset.PrivateIpAddress] = MC.aws.aws.genResRef(uid, "resource.PrivateIpAddressSet.#{idx}.PrivateIpAddress")

        #replace reference
        for uid, comp of canvas_component

            canvas_component[uid] = replaceReference comp, key, constant.AWS_RESOURCE_KEY[comp.type]

        [canvas_component, key]


    replaceReference = ( obj, reference, except_key ) ->

        switch typeof(obj)

            when 'object'

                for k, v of obj

                    if typeof(v) is 'string'

                        if k is 'LaunchConfigurationName'

                            if reference[v + '-lc'] and k not in [except_key, 'name']

                                obj[k] = reference[v + '-lc']

                        else if k is 'AutoScalingGroupName'

                            if reference[v + '-asg'] and k not in [except_key, 'name']

                                obj[k] = reference[v + '-asg']

                        else if k is 'KeyName'

                            if reference[v + '-keypair'] and k not in [except_key, 'name'] and not obj.KeyFingerprint

                                obj[k] = reference[v + '-keypair']

                        else if reference[v] and k not in [except_key, 'name']

                            obj[k] = reference[v]

                    if typeof(v) is 'object'

                        replaceReference obj[k], reference, except_key

                    if typeof(v) is 'array'

                        replaceReference obj[k], reference, except_key

            when 'array'

                for index, slot of obj

                    if typeof(v) is 'string' and reference[slot]

                        obj[index] = reference[slot]

                    if typeof(v) is 'object'

                        replaceReference obj[index], reference, except_key

                    if typeof(v) is 'array'

                        replaceReference obj[index], reference, except_key

        obj

            # switch comp.type

            #     when 'AWS.EC2.Instance'

            #         key[comp.resource.InstanceId] = "@#{uid}.resource.InstanceId"

            #     when 'AWS.EC2.EBS.Volume'

            #         key[comp.resource.VolumeId] = "@#{uid}.resource.VolumeId"

            #     when 'AWS.VPC.NetworkInterface'

            #         key[comp.resource.NetworkInterfaceId] = "@#{uid}.resource.NetworkInterfaceId"

            #     when 'AWS.VPC.DhcpOptions'

            #         key[comp.resource.DhcpOptionsId] = "@#{uid}.resource.DhcpOptionsId"

            #     when 'AWS.VPC.VPC'

            #         key[comp.resource.VpcId] = "@#{uid}.resource.VpcId"

            #     when 'AWS.VPC.Subnet'

            #         key[comp.resource.SubnetId] = "@#{uid}.resource.SubnetId"

            #     when 'AWS.VPC.SecurityGroup'

            #         key[comp.resource.GroupId] = "@#{uid}.resource.GroupId"

    genResRef = (uid, attrName) ->

        return "@{#{uid}.#{attrName}}"

    enableStackAgent = (isEnable) ->

        agentData = Design.instance().get('agent')
        agentData.enabled = isEnable
        Design.instance().set('agent', agentData)
        # MC.common.other.canvasData.initSet('agent', agentData)

    getCompByResIdForState = ( resId ) ->

        result =
            parent: null
            self: null

        Design.instance().eachComponent ( component ) ->
            groupMembers = component.groupMembers and component.groupMembers()
            resourceInList = MC.data.resource_list[ Design.instance().region() ]
            if result.parent or result.self
                null
            if component.get( 'appId' ) is resId
                # ServerGroup
                if groupMembers and groupMembers.length
                    result.parent = component
                    result.self = new Backbone.Model 'name': "#{component.get 'name'}-0"
                # Instance
                else
                    result.self = component
                null
            # ServerGroup
            else if groupMembers and resId in _.pluck( groupMembers, 'appId' )
                if component.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
                    result.parent = component.parent()
                else
                    result.parent = component
                    for index, member of groupMembers
                        if member.appId is resId
                            result.self = new Backbone.Model 'name': "#{component.get 'name'}-#{+index + 1}"
                            break
                null

        result

    checkPrivateIPIfHaveEIP = (allCompData, eniUID, priIPNum) ->

        haveEIP = false
        _.each allCompData, (compData) ->

            if compData.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
                currentENIUIDRef = compData.resource.NetworkInterfaceId
                currentENIUID = MC.extractID(currentENIUIDRef)
                if eniUID is currentENIUID
                    currentPriIPNumAry = compData.resource.PrivateIpAddress.split('.')
                    currentPriIPNum = currentPriIPNumAry[3]
                    if Number(currentPriIPNum) is priIPNum
                        haveEIP = true
            null
        return haveEIP

    genAttrRefList = (currentCompData, allCompData) ->

        currentCompUID = currentCompData.uid
        currentCompType = currentCompData.type

        currentIsASG = false
        currentASGName = null
        if currentCompType is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
            currentIsASG = true

        currentIsISG = false
        currentIsInstance = false
        currentInstanceName = null
        currentISGName = null
        if currentCompData.number
            if currentCompData.number > 1
                currentIsISG = true
                currentISGName = currentCompData.serverGroupName
            else
                currentIsInstance = true
                currentInstanceName = currentCompData.serverGroupName

        allCompData = allCompData or @get('allCompData')

        autoCompList = []

        awsPropertyData = MC.data.state.aws_property

        # compTypeMap = constant.AWS_RESOURCE_TYPE

        _.each allCompData, (compData, uid) ->

            compName = compData.name
            compUID = compData.uid
            compType = compData.type

            checkASGPublicIP = false

            if compUID is currentCompUID
                compName = 'self'

            if compType is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
                lcUIDRef = compData.resource.LaunchConfigurationName
                if lcUIDRef
                    lcUID = MC.extractID(lcUIDRef)
                    lcCompData = allCompData[lcUID]
                    if currentCompType is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration and currentCompUID is lcUID
                        currentASGName = compName
                        compName = 'self'
                        asgHaveSelf = true

                    if lcCompData.resource.AssociatePublicIpAddress
                        asgHavePublicIP = true

            if compType is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
                return

            # replace instance default eni name to instance name
            if compType is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
                if compData.index isnt 0
                    return
                if compData.serverGroupUid isnt compUID
                    return
                instanceRef = compData.resource.Attachment.InstanceId
                if not instanceRef
                    return
                if compData.resource.Attachment.DeviceIndex in ['0', 0]
                    instanceUID = MC.extractID(instanceRef)
                    if instanceUID
                        compName = allCompData[instanceUID].serverGroupName
                        compUID = instanceUID
                        if instanceUID is currentCompUID
                            compName = 'self'

            supportType = compType.replace(/\./ig, '_')

            # found supported type
            attrList = awsPropertyData[supportType]
            if attrList

                _.each attrList, (isArray, attrName) ->

                    autoCompStr = (compName + '.') # host1.
                    autoCompRefStr = (compUID + '.') # uid.

                    if attrName is '__array'
                        return
                    else
                        autoCompStr += attrName
                        autoCompRefStr += attrName

                    instanceNoMainPublicIP = false

                    if attrName in ['PublicIp']

                        if compType is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
                            if not asgHavePublicIP
                                return

                        if compType is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
                            if (not MC.aws.aws.checkPrivateIPIfHaveEIP(allCompData, compData.uid, 0)) and
                            (not compData.resource.AssociatePublicIpAddress)
                                instanceNoMainPublicIP = true

                    if not instanceNoMainPublicIP

                        autoCompList.push({
                            name: autoCompStr,
                            value: autoCompRefStr,
                            uid: compUID
                        })

                    if isArray

                        if supportType is 'AWS_AutoScaling_Group'
                            if attrName in ['AvailabilityZones']
                                azAry = compData.resource.AvailabilityZones
                                if azAry.length > 1
                                    _.each azAry, (azName, idx) ->
                                        # if idx is 0 then return
                                        autoCompList.push({
                                            name: autoCompStr + '[' + idx + ']',
                                            value: autoCompRefStr + '[' + idx + ']',
                                            uid: compUID
                                        })
                                        null

                        if supportType is 'AWS_VPC_NetworkInterface'
                            if attrName in ['PublicDnsName', 'PublicIp', 'PrivateDnsName', 'PrivateIpAddress']
                                ipObjAry = compData.resource.PrivateIpAddressSet
                                if compData.index isnt 0
                                    return
                                if ipObjAry.length > 1
                                    _.each ipObjAry, (ipObj, idx) ->
                                        if idx is 0 then return
                                        if attrName in ['PublicIp']
                                            if not MC.aws.aws.checkPrivateIPIfHaveEIP(allCompData, compData.uid, idx)
                                                return
                                        autoCompList.push({
                                            name: autoCompStr + '[' + idx + ']',
                                            value: autoCompRefStr + '[' + idx + ']',
                                            uid: compUID
                                        })
                                        null

                        if supportType is 'AWS_ELB'
                            if attrName in ['AvailabilityZones']
                                azAry = compData.resource.AvailabilityZones
                                if azAry.length > 1
                                    _.each azAry, (azName, idx) ->
                                        # if idx is 0 then return
                                        autoCompList.push({
                                            name: autoCompStr + '[' + idx + ']',
                                            value: autoCompRefStr + '[' + idx + ']',
                                            uid: compUID
                                        })
                                        null

                    null

            null

        # append asg/isg ref
        groupAutoCompList = []
        instanceAutoCompList = []
        _.each autoCompList, (autoCompObj) ->
            if autoCompObj.name.indexOf('self.') is 0

                if currentIsInstance
                    instanceCompNameStr = autoCompObj.name.replace('self', currentInstanceName)
                    instanceCompUIDStr = autoCompObj.value.replace('self', currentInstanceName)
                    instanceAutoCompList.push({
                        name: instanceCompNameStr,
                        value: instanceCompUIDStr,
                        uid: autoCompObj.uid
                    })

                if currentIsASG or currentIsISG
                    groupCompNameStr = null
                    groupCompUIDStr = null
                    if currentIsASG
                        groupCompNameStr = autoCompObj.name.replace('self', currentASGName)
                        groupCompUIDStr = autoCompObj.value.replace('self', currentASGName)
                    else if currentIsISG
                        groupCompNameStr = autoCompObj.name.replace('self', currentISGName)
                        groupCompUIDStr = autoCompObj.value.replace('self', currentISGName)
                    groupAutoCompList.push({
                        name: groupCompNameStr,
                        value: groupCompUIDStr,
                        uid: autoCompObj.uid
                    })

        autoCompList = autoCompList.concat(groupAutoCompList)
        autoCompList = autoCompList.concat(instanceAutoCompList)

        resAttrDataAry = _.map autoCompList, (autoCompObj) ->

            if autoCompObj.name.indexOf('self.') is 0
                autoCompObj.value = autoCompObj.value.replace(autoCompObj.uid, 'self')
                autoCompObj.uid = 'self'
            return {
                name: "#{autoCompObj.name}",
                value: "#{autoCompObj.name}",
                ref: "#{autoCompObj.value}",
                uid: "#{autoCompObj.uid}"
            }

        # filter all self's AZ ref
        resAttrDataAry = _.filter resAttrDataAry, (autoCompObj) ->

            if autoCompObj.name.indexOf('self.') is 0
                if autoCompObj.name.indexOf('.AvailabilityZones') isnt -1
                    return false
                else
                    return true

            return true

        # sort autoCompList
        resAttrDataAry = resAttrDataAry.sort((obj1, obj2) ->
            if obj1.name < obj2.name then return -1
            if obj1.name > obj2.name then return 1
        )

        return resAttrDataAry


    convertBlockDeviceMapping = (ami) ->

        data = {}
        if ami and ami.blockDeviceMapping and ami.blockDeviceMapping.item
            for value,idx in ami.blockDeviceMapping.item

                if value.ebs
                    data[value.deviceName] =
                        snapshotId : value.ebs.snapshotId
                        volumeSize : value.ebs.volumeSize
                        volumeType : value.ebs.volumeType
                        deleteOnTermination : value.ebs.deleteOnTermination
                else
                    data[value.deviceName] = {}

                ami.blockDeviceMapping = data
        else
            console.warn "convertBlockDeviceMapping(): nothing to convert"
        null


    isValidInIPRange = (ipStr, validIPType) ->

        pubIPAry = [
            {
                low: '1.0.0.1',
                high: '126.255.255.254'
            },
            {
                low: '128.1.0.1',
                high: '191.254.255.254'
            },
            {
                low: '192.0.1.1',
                high: '223.255.254.254'
            }
        ]

        priIPAry = [
            {
                low: '10.0.0.0',
                high: '10.255.255.255'
            },
            {
                low: '172.16.0.0',
                high: '172.31.255.255'
            },
            {
                low: '192.168.0.0',
                high: '192.168.255.255'
            }
        ]

        ipRangeValid = (ipAryStr1, ipAryStr2, ipStr) ->

            ipAry1 = ipAryStr1.split('.')
            ipAry2 = ipAryStr2.split('.')
            curIPAry = ipStr.split('.')

            isInIPRange = true
            _.each curIPAry, (ipNum, idx) ->
                if not (Number(curIPAry[idx]) >= Number(ipAry1[idx]) and
                Number(curIPAry[idx]) <= Number(ipAry2[idx]))
                    isInIPRange = false
                null

            return isInIPRange

        ipRangeAry = []

        if validIPType is 'public'
            ipRangeAry = pubIPAry
        else if validIPType is 'private'
            ipRangeAry = priIPAry

        isInAryRange = false
        _.each ipRangeAry, (ipRangeObj) ->
            lowRange = ipRangeObj.low
            highRange = ipRangeObj.high
            isInRange = ipRangeValid(lowRange, highRange, ipStr)
            if isInRange
                isInAryRange = true
            null

        return isInAryRange

    #public
    collectReference            : collectReference
    cacheResource               : cacheResource
    checkIsRepeatName           : checkIsRepeatName
    checkStackName              : checkStackName
    checkAppName                : checkAppName
    getDuplicateName            : getDuplicateName
    getOSFamily                 : getOSFamily
    genResRef                   : genResRef
    enableStackAgent            : enableStackAgent
    getCompByResIdForState      : getCompByResIdForState
    genAttrRefList              : genAttrRefList
    isValidInIPRange            : isValidInIPRange
    checkPrivateIPIfHaveEIP     : checkPrivateIPIfHaveEIP
