define [ 'constant', 'MC', 'Design', 'TaHelper' ], ( constant, MC, Design, Helper ) ->

    i18n = Helper.i18n.short()
    isEBSOptimizedForAttachedProvisionedVolume = (instanceUID) ->

        instanceComp = MC.canvas_data.component[instanceUID]
        instanceType = instanceComp.type
        isInstanceComp = instanceType is constant.RESTYPE.INSTANCE
        # check if the instance/lsg have provisioned volume
        haveProvisionedVolume = false
        instanceUIDRef = lsgName = amiId = null
        if instanceComp
            instanceUIDRef = MC.genResRef(instanceUID, 'resource.InstanceId')
        else
            lsgName = instanceComp.resource.LaunchConfigurationName
            amiId = instanceComp.resource.ImageId
        _.each MC.canvas_data.component, (compObj) ->
            if compObj.type is constant.RESTYPE.VOL
                if compObj.resource.VolumeType isnt 'standard'
                    # if instanceComp is instance
                    if isInstanceComp and (compObj.resource.AttachmentSet.InstanceId is instanceUIDRef)
                        haveProvisionedVolume = true
                    # if instanceComp is LSG
                    else if (!isInstanceComp and compObj.resource.ImageId is amiId and compObj.resource.LaunchConfigurationName is lsgName)
                        haveProvisionedVolume = true
            null

        # check if the instance/lsg is EbsOptimized
        if !(haveProvisionedVolume and (instanceComp.resource.EbsOptimized in ['false', false, '']))
            return null
        else
            instanceName = instanceComp.name
            tipInfo = sprintf i18n.NOTICE_INSTANCE_NOT_EBS_OPTIMIZED_FOR_ATTACHED_PROVISIONED_VOLUME, instanceName
            # return
            level: constant.TA.NOTICE
            info: tipInfo
            uid: instanceUID

    _getSGCompRuleLength = (sgUID) ->
        sgComp = MC.canvas_data.component[sgUID]
        sgInboundRuleAry = sgComp.resource.IpPermissions
        sgOutboundRuleAry = sgComp.resource.IpPermissionsEgress

        # count sg rule total number
        sgTotalRuleNum = 0
        if sgInboundRuleAry
            sgTotalRuleNum += sgInboundRuleAry.length
        if sgOutboundRuleAry
            sgTotalRuleNum += sgOutboundRuleAry.length
        return sgTotalRuleNum

    isAssociatedSGRuleExceedFitNum = (instanceUID) ->

        instanceComp = MC.canvas_data.component[instanceUID]
        instanceType = instanceComp.type
        isInstanceComp = instanceType is constant.RESTYPE.INSTANCE
        # check platform type

        # have vpc, count eni's sg rule number
        sgUIDAry = []
        if isInstanceComp
            # get associated eni sg for instance
            _.each MC.canvas_data.component, (compObj) ->
                if compObj.type is constant.RESTYPE.ENI
                    associatedInstanceRef = compObj.resource.Attachment.InstanceId
                    associatedInstanceUID = MC.extractID(associatedInstanceRef)
                    if associatedInstanceUID is instanceUID
                        eniSGAry = compObj.resource.GroupSet
                        _.each eniSGAry, (sgObj) ->
                            eniSGUIDRef = sgObj.GroupId
                            eniSGUID = MC.extractID(eniSGUIDRef)
                            if !(eniSGUID in sgUIDAry)
                                sgUIDAry.push(eniSGUID)
                            null
                null

            # loop sg array to count rule number
            totalSGRuleNum = 0
            _.each sgUIDAry, (sgUID) ->
                totalSGRuleNum += _getSGCompRuleLength(sgUID)
                null

            if totalSGRuleNum > 50
                instanceName = instanceComp.name
                tipInfo = sprintf i18n.WARNING_INSTANCE_SG_RULE_EXCEED_FIT_NUM, instanceName, 50
                return {
                    level: constant.TA.WARNING,
                    info: tipInfo,
                    uid: instanceUID
                }

        else
            # no vpc
            sgUIDAry = []
            if isInstanceComp
                instanceSGAry = instanceComp.resource.SecurityGroup
            else
                instanceSGAry = instanceComp.resource.SecurityGroups
            _.each instanceSGAry, (sgRef) ->
                sgUID = MC.extractID(sgRef)
                if !(sgUID in sgUIDAry)
                    sgUIDAry.push(sgUID)
                null

            # loop sg array to count rule number
            totalSGRuleNum = 0
            _.each sgUIDAry, (sgUID) ->
                totalSGRuleNum += _getSGCompRuleLength(sgUID)
                null

            if totalSGRuleNum > 100
                instanceName = instanceComp.name
                tipInfo = sprintf i18n.WARNING_INSTANCE_SG_RULE_EXCEED_FIT_NUM, instanceName, 100
                return {
                    level: constant.TA.WARNING,
                    info: tipInfo,
                    uid: instanceUID
                }

        return null

    isConnectRoutTableButNoEIP = ( uid ) ->
        components = MC.canvas_data.component
        instance = components[ uid ]
        instanceId = MC.genResRef(uid, 'resource.InstanceId')
        RTB = ''

        isConnectRTB = _.some components, ( component ) ->
            if component.type is constant.RESTYPE.RT
                _.some component.resource.RouteSet, ( rt ) ->
                    if rt.InstanceId is instanceId
                        RTB = component
                        return true

        hasEIP = _.some components, ( component ) ->
            if component.type is constant.RESTYPE.EIP and component.resource.InstanceId is instanceId
                    return true

        if not isConnectRTB or hasEIP
            return null


        tipInfo = sprintf i18n.NOTICE_INSTANCE_HAS_RTB_NO_ELB, RTB.name, instance.name, instance.name

        # return
        level   : constant.TA.NOTICE
        info    : tipInfo
        uid     : uid


    isNatCheckedSourceDest = ( uid ) ->
        instance = Design.instance().component uid

        # InstanceGroup member which isn't main has no resourceModel
        if not instance then return null

        connectedRt = instance.connectionTargets 'RTB_Route'
        if connectedRt and connectedRt.length
            enis = instance.connectionTargets('EniAttachment')
            enis.push instance.getEmbedEni()
            hasUncheck = _.some enis, ( eni ) ->
                not eni.get 'sourceDestCheck'
            if not hasUncheck
                return Helper.message.error uid, i18n.ERROR_INSTANCE_NAT_CHECKED_SOURCE_DEST, instance.get 'name'
            null

        null

    isMesosHasSlave = ->
        unless Design.instance().opsModel().isMesos() then return null

        hasSlave = Design.modelClassForType( constant.RESTYPE.INSTANCE ).some ( i ) -> i.isMesosSlave()
        hasSlaveLc = Design.modelClassForType( constant.RESTYPE.LC ).some ( i ) -> i.isMesosSlave()

        if hasSlave or hasSlaveLc then return null

        Helper.message.error null, i18n.MESOS_STACK_NEED_A_SLAVE_NODE_AT_LEAST

    isMesosMasterCountLegal = ->
        unless Design.instance().opsModel().isMesos() then return null

        errors = []
        masterCount = Design.modelClassForType( constant.RESTYPE.INSTANCE ).reduce ( memo, i ) ->
            if i.isMesosMaster() then memo + 1 else memo
        , 0

        if masterCount < 3
            errors.push Helper.message.error 'IS_MESOS_MASTER_MORE_THAN_3', i18n.IS_MESOS_MASTER_MORE_THAN_3

        if masterCount % 2 is 0
            errors.push Helper.message.error 'MASTER_NUMBER_MUST_BE_ODD', i18n.MASTER_NUMBER_MUST_BE_ODD

        errors


    isMesosMasterPlacedInPublicSubnet = ->
        privateMasters = Design.modelClassForType( constant.RESTYPE.INSTANCE ).filter ( i ) ->
            i.isMesosMaster() and !i.parent().isPublic()

        unless privateMasters.length then return null

        nameStr = ''
        for master in privateMasters
            nameStr += "<span class='validation-tag tag-mesos-master'>#{master.get('name')}</span>, "

        nameStr = nameStr.slice 0, -2
        Helper.message.error null, i18n.MASTER_NODE_MUST_BE_PLACED_IN_A_PUBLIC_SUBNET, nameStr

    isInstanceOrLcConnectable = ->
        lonelySb = []

        Design.modelClassForType( constant.RESTYPE.INSTANCE ).each ( i ) ->
            sb = i.parent()
            if i.isPublic() and !sb.isPublic() then lonelySb.push sb

        Design.modelClassForType( constant.RESTYPE.LC ).each ( lc ) ->
            if lc.isPublic()
                asgs = lc.getAsgsIncludeExpanded()
                for asg in asgs
                    sb = asg.parent()
                    if !sb.isPublic() then lonelySb.push sb

        Design.modelClassForType( constant.RESTYPE.ENI ).each ( eni ) ->
            if !eni.embedInstance() and eni.hasEip()
                sb = eni.parent()
                lonelySb.push sb unless sb.isPublic()

        lonelySb = _.uniq lonelySb

        unless lonelySb.length then return null

        nameStr = ''
        for sb in lonelySb
            nameStr += "Subnet <span class='validation-tag tag-subnet'>#{sb.get('name')}</span>, "

        nameStr = nameStr.slice 0, -2
        Helper.message.error null, i18n.SUBNET_CONNECTIVITY, nameStr




    isEBSOptimizedForAttachedProvisionedVolume  : isEBSOptimizedForAttachedProvisionedVolume
    isAssociatedSGRuleExceedFitNum              : isAssociatedSGRuleExceedFitNum
    isConnectRoutTableButNoEIP                  : isConnectRoutTableButNoEIP
    isNatCheckedSourceDest                      : isNatCheckedSourceDest
    isMesosHasSlave                             : isMesosHasSlave
    isMesosMasterCountLegal                     : isMesosMasterCountLegal
    isMesosMasterPlacedInPublicSubnet           : isMesosMasterPlacedInPublicSubnet
    isInstanceOrLcConnectable                   : isInstanceOrLcConnectable


