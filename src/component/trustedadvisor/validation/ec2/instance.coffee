define [ 'constant', 'MC','i18n!nls/lang.js'], ( constant, MC, lang ) ->

	isEBSOptimizedForAttachedProvisionedVolume = (instanceUID) ->

		instanceComp = MC.canvas_data.component[instanceUID]
		instanceType = instanceComp.type
		isInstanceComp = instanceType is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
		# check if the instance/lsg have provisioned volume
		haveProvisionedVolume = false
		instanceUIDRef = lsgName = amiId = null
		if instanceComp
			instanceUIDRef = '@' + instanceUID + '.resource.InstanceId'
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
			tipInfo = sprintf lang.ide.TA_INFO_NOTICE_INSTANCE_NOT_EBS_OPTIMIZED_FOR_ATTACHED_PROVISIONED_VOLUME, instanceName
			# return
			level: constant.TA.NOTICE
			info: tipInfo

	isEBSOptimizedForAttachedProvisionedVolume : isEBSOptimizedForAttachedProvisionedVolume