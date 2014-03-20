define [ 'constant', 'MC','i18n!nls/lang.js', 'Design', 'validation_helper' ], ( constant, MC, lang, Design, Helper ) ->

	isEBSOptimizedForAttachedProvisionedVolume = (instanceUID) ->

		instanceComp = MC.canvas_data.component[instanceUID]
		instanceType = instanceComp.type
		isInstanceComp = instanceType is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
		# check if the instance/lsg have provisioned volume
		haveProvisionedVolume = false
		instanceUIDRef = lsgName = amiId = null
		if instanceComp
			instanceUIDRef = MC.aws.aws.genResRef(instanceUID, 'resource.InstanceId')
		else
			lsgName = instanceComp.resource.LaunchConfigurationName
			amiId = instanceComp.resource.ImageId
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume
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
			tipInfo = sprintf lang.ide.TA_MSG_NOTICE_INSTANCE_NOT_EBS_OPTIMIZED_FOR_ATTACHED_PROVISIONED_VOLUME, instanceName
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
		isInstanceComp = instanceType is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
		# check platform type
		platformType = MC.canvas_data.platform
		if platformType isnt MC.canvas.PLATFORM_TYPE.EC2_CLASSIC
			# have vpc, count eni's sg rule number
			sgUIDAry = []
			if isInstanceComp
				# get associated eni sg for instance
				_.each MC.canvas_data.component, (compObj) ->
					if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
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
			else
				# get all LSG's sg
				lsgSGAry = instanceComp.resource.SecurityGroups
				_.each lsgSGAry, (sgRef) ->
					sgUID = MC.extractID(sgRef)
					if !(sgUID in sgUIDAry)
						sgUIDAry.push(sgUID)
					null

			# loop sg array to count rule number
			totalSGRuleNum = 0
			_.each sgUIDAry, (sgUID) ->
				totalSGRuleNum += _getSGCompRuleLength(sgUID)
				null

			if totalSGRuleNum > 50
				instanceName = instanceComp.name
				tipInfo = sprintf lang.ide.TA_MSG_WARNING_INSTANCE_SG_RULE_EXCEED_FIT_NUM, instanceName, 50
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
				tipInfo = sprintf lang.ide.TA_MSG_WARNING_INSTANCE_SG_RULE_EXCEED_FIT_NUM, instanceName, 100
				return {
					level: constant.TA.WARNING,
					info: tipInfo,
					uid: instanceUID
				}

		return null

	isConnectRoutTableButNoEIP = ( uid ) ->
        components = MC.canvas_data.component
        instance = components[ uid ]
        instanceId = MC.aws.aws.genResRef(uid, 'resource.InstanceId')
        RTB = ''

        isConnectRTB = _.some components, ( component ) ->
        	if component.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
        		_.some component.resource.RouteSet, ( rt ) ->
        			if rt.InstanceId is instanceId
        				RTB = component
        				return true

        hasEIP = _.some components, ( component ) ->
        	if component.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and component.resource.InstanceId is instanceId
        			return true

       	if not isConnectRTB or hasEIP
       		return null


        tipInfo = sprintf lang.ide.TA_MSG_NOTICE_INSTANCE_HAS_RTB_NO_ELB, RTB.name, instance.name, instance.name

        # return
        level   : constant.TA.NOTICE
        info    : tipInfo
        uid     : uid


	isNatCheckedSourceDest = ( uid ) ->
		instance = Design.instance().component uid
		connectedRt = instance.connectionTargets 'RTB_Route'
		if connectedRt and connectedRt.length
			enis = instance.connectionTargets('EniAttachment')
			enis.push instance.getEmbedEni()
			hasUncheck = _.some enis, ( eni ) ->
				not eni.get 'sourceDestCheck'
			if not hasUncheck
				return Helper.message.error uid, lang.ide.TA_MSG_ERROR_INSTANCE_NAT_CHECKED_SOURCE_DEST, instance.get 'name'
			null

		null


	isEBSOptimizedForAttachedProvisionedVolume 	: isEBSOptimizedForAttachedProvisionedVolume
	isAssociatedSGRuleExceedFitNum 				: isAssociatedSGRuleExceedFitNum
	isConnectRoutTableButNoEIP				 	: isConnectRoutTableButNoEIP
	isNatCheckedSourceDest						: isNatCheckedSourceDest


