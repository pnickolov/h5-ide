define [ 'MC', 'constant', 'underscore', 'jquery', 'Design', 'i18n!/nls/lang.js' ], ( MC, constant, _, $, Design, lang ) ->

    getCompByResIdForState = ( resId ) ->

        result =
            parent: null
            self: null

        Design.instance().eachComponent ( component ) ->
            groupMembers = component.groupMembers and component.groupMembers()
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
                if component.type is constant.RESTYPE.LC
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

            if compData.type is constant.RESTYPE.EIP
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

        cloudType = Design.instance().get('cloud_type')

        resAttrDataAry = []

        if cloudType is 'aws'

            _getSelectedASGModelByLC = () ->

                $asgDom = $('#OpsEditor g.AWS-AutoScaling-LaunchConfiguration.selected').parent('g.AWS-AutoScaling-Group')
                asgViewId = $asgDom.data('id')
                return App.workspaces.getAwakeSpace().view.canvas.getItem(asgViewId).model if asgViewId
                return null

            if currentCompData.type is constant.RESTYPE.ASG

                lcUIDRef = currentCompData.resource.LaunchConfigurationName
                if lcUIDRef
                    lcUID = MC.extractID(lcUIDRef)
                    currentCompData = allCompData[lcUID]
                    return null if not currentCompData

            currentCompUID = currentCompData.uid
            currentCompType = currentCompData.type

            currentIsASG = false
            currentASGName = null
            if currentCompType is constant.RESTYPE.LC
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

            awsPropertyData = constant.STATE_REF_DICT

            _.each allCompData, (compData, uid) ->

                compName = compData.name
                compUID = compData.uid
                compType = compData.type

                checkASGPublicIP = false

                if compUID is currentCompUID
                    compName = 'self'

                if compType is constant.RESTYPE.ASG
                    lcUIDRef = compData.resource.LaunchConfigurationName
                    if lcUIDRef
                        lcUID = MC.extractID(lcUIDRef)
                        lcCompData = allCompData[lcUID]
                        if currentCompType is constant.RESTYPE.LC and currentCompUID is lcUID
                            asgModel = _getSelectedASGModelByLC()
                            if asgModel and asgModel.get('id') is compUID
                                currentASGName = compName
                                compName = 'self'

                        if lcCompData.resource.AssociatePublicIpAddress
                            asgHavePublicIP = true

                if compType is constant.RESTYPE.INSTANCE
                    return

                # replace instance default eni name to instance name
                if compType is constant.RESTYPE.ENI
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

                            if compType is constant.RESTYPE.ASG
                                if not asgHavePublicIP
                                    return

                            if compType is constant.RESTYPE.ENI
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
                                            # if idx is 0 then return
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

            # add self refrence for temp
            allAttrStrAry = _.map resAttrDataAry, (refObj) ->
                return refObj.name
            _.each ['self.PrivateIpAddress', 'self.MacAddress', 'self.PublicIp'], (attr) ->
                if attr not in allAttrStrAry
                    resAttrDataAry.push {
                        name: "#{attr}",
                        value: "#{attr}",
                        ref: "#{attr}",
                        uid: "self"
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

        else # for openstack

            # # for host
            # xxx.ip_address
            # xxx.mac_address
            # xxx.public_ip
            #
            # # for port
            # xxx.ip_address
            # xxx.mac_address
            # xxx.public_ip
            #
            # # for listener
            # xxx.ip_address
            # xxx.protocol
            # xxx.port
            #
            # # for subnet
            # xxx.cidr
            # xxx.gateway_ip
            #
            # # for state
            # xxx.state.n

            currentCompUID = currentCompData.uid
            currentResModel = Design.instance().component(currentCompUID)

            _genRefObj = (name, uid, attr) ->

                return {
                    name: "#{name}.#{attr}",
                    ref: "#{uid}.#{attr}",
                    uid: "#{uid}.#{attr}",
                    value: "#{name}.#{attr}"
                }

            # for port
            allPortModels = Design.modelClassForType(constant.RESTYPE.OSPORT).allObjects()
            _.each allPortModels, (portModel) ->

                name = portModel.get('name')
                if portModel.isEmbedded()
                    name = portModel.owner()?.get('name')

                uid = portModel.id

                return if not (name and uid)

                # for ip_address, mac_address
                resAttrDataAry = resAttrDataAry.concat([
                    _genRefObj(name, uid, 'ip_address'),
                    _genRefObj(name, uid, 'mac_address')
                ])

                # for public_ip
                floatIPModel = portModel.getFloatingIp()
                if floatIPModel
                    uid = floatIPModel.id
                    resAttrDataAry = resAttrDataAry.concat([
                        _genRefObj(name, uid, 'public_ip')
                    ])

            # for listener
            allListenerModels = Design.modelClassForType(constant.RESTYPE.OSLISTENER).allObjects()
            _.each allListenerModels, (listenerModel) ->

                name = listenerModel.get('name')
                uid = listenerModel.id

                # for ip_address, protocol, port
                resAttrDataAry = resAttrDataAry.concat([
                    _genRefObj(name, uid, 'ip_address'),
                    _genRefObj(name, uid, 'mac_address'),
                    _genRefObj(name, uid, 'protocol'),
                    _genRefObj(name, uid, 'port')
                ])

                # for public_ip
                floatIPModel = listenerModel.getFloatingIp()
                if floatIPModel
                    uid = floatIPModel.id
                    resAttrDataAry = resAttrDataAry.concat([
                        _genRefObj(name, uid, 'public_ip')
                    ])

            # for subnet
            allSubnetModels = Design.modelClassForType(constant.RESTYPE.OSSUBNET).allObjects()
            _.each allSubnetModels, (subnetModel) ->

                name = subnetModel.get('name')
                uid = subnetModel.id

                # for ip_address, protocol, port
                resAttrDataAry = resAttrDataAry.concat([
                    _genRefObj(name, uid, 'cidr')
                ])

        return resAttrDataAry

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

    checkResName = ( uid, $input, type ) ->

        isNameDup = ( uid, newName )->

            console.assert( uid, "This property model doesn't have an id" )

            comp = Design.instance().component( uid )

            if comp.get("name") is newName
                return false

            dup = false
            Design.instance().eachComponent ( comp )->
                if comp.get("name") is newName
                    dup = true
                    return false

            dup

        isOldName = ( uid, newName )->
            design = Design.instance()
            comp = design.component( uid )
            if not comp then return false
            design.isPreservedName( comp.type, newName )

        isReservedName = ( newName ) ->

            result = false
            if newName in ['self', 'this', 'global', 'meta', 'madeira']
                result = true

            return result

        if not $input.length
            $input = $( $input )

        name = $input.val()

        if not type then type = name

        if name && !MC.validate( 'awsName',  name )
            error = sprintf lang.PARSLEY.THIS_VALUE_SHOULD_BE_A_VALID_TYPE_NAME, type

        if not error and isNameDup( uid, name )
            error = sprintf lang.PARSLEY.TYPE_NAME_CONFLICT, type, name

        if not error and isOldName( uid, name )
            error = sprintf lang.PARSLEY.TYPE_NAME_CONFLICT, type, name

        if not error and isReservedName( name )
            error = sprintf lang.PARSLEY.TYPE_NAME_CONFLICT, type, name

        if name.indexOf("elbsg-") is 0
            error = lang.PARSLEY.RESOURCE_NAME_ELBSG_RESERVED

        $input.parsley 'custom', ()-> error
        $input.parsley 'validate'

    #public
    MC.aws = {}
    MC.aws.aws =
        getCompByResIdForState      : getCompByResIdForState
        genAttrRefList              : genAttrRefList
        isValidInIPRange            : isValidInIPRange
        checkPrivateIPIfHaveEIP     : checkPrivateIPIfHaveEIP
        checkResName                : checkResName

    return
