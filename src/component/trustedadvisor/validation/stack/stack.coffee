define [ 'constant', 'jquery', 'MC','i18n!nls/lang.js', 'ApiRequest', 'stack_service', 'ami_service', '../result_vo' ], ( constant, $, MC, lang, ApiRequest, stackService, amiService ) ->

	getAZAryForDefaultVPC = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]
		elbInstances = elbComp.resource.Instances
		azNameAry = []

		_.each elbInstances, (instanceRefObj) ->
			instanceRef = instanceRefObj.InstanceId
			instanceUID = MC.extractID(instanceRef)
			instanceAZName = MC.canvas_data.component[instanceUID].resource.Placement.AvailabilityZone
			if !(instanceAZName in azNameAry)
				azNameAry.push(instanceAZName)
			null

		return azNameAry

	_getCompName = (compUID) ->

		compName = ''
		compObj = MC.canvas_data.component[compUID]
		if compObj and compObj.name
			compName = compObj.name
		return compName

	_getCompType = (compUID) ->

		compType = ''
		compObj = MC.canvas_data.component[compUID]
		if compObj and compObj.type
			compType = compObj.type
		return compType

	verify = (callback) ->

		try
			if !callback
				callback = () ->

			validData = MC.canvas_data

			ApiRequest('stack_verify', {
				username: $.cookie( 'usercode' ),
				session_id: $.cookie( 'session_id' ),
				spec: validData
			}).then (result) ->

				checkResult = true
				returnInfo = null
				errInfoStr = ''

				if result isnt true

					checkResult = false

					try
						
						returnInfo = result
						returnInfoObj = JSON.parse(returnInfo)

						# get api call info
						errCompUID = returnInfoObj.uid

						errCode = returnInfoObj.code
						errKey = returnInfoObj.key
						errMessage = returnInfoObj.message

						errCompName = _getCompName(errCompUID)
						errCompType = _getCompType(errCompUID)

						errInfoStr = sprintf lang.ide.TA_MSG_ERROR_STACK_FORMAT_VALID_FAILED, errCompName, errMessage

						if (errCode is 'EMPTY_VALUE' and
							errKey is 'InstanceId' and
							errMessage is 'Key InstanceId can not empty' and
							errCompType is 'AWS.VPC.NetworkInterface')
								checkResult = true

						if (errCode is 'EMPTY_VALUE' and
							errKey is 'LaunchConfigurationName' and
							errMessage is 'Key LaunchConfigurationName can not empty' and
							errCompType is 'AWS.AutoScaling.Group')
								checkResult = true

					catch err
						errInfoStr = "Stack format validation error"
				else
					callback(null)

				if checkResult
					callback(null)
				else
					validResultObj = {
						level: constant.TA.ERROR,
						info: errInfoStr
					}
					callback(validResultObj)
					console.log(validResultObj)

			, (result) ->

				callback(null)

			# immediately return
			tipInfo = sprintf lang.ide.TA_MSG_ERROR_STACK_CHECKING_FORMAT_VALID
			return {
				level: constant.TA.ERROR,
				info: tipInfo
			}
		catch err
			callback(null)

	isHaveNotExistAMIAsync = (callback) ->

		try
			if !callback
				callback = () ->

			currentState = MC.canvas.getState()

			# get current all using ami
			amiAry = []
			instanceAMIMap = {}
			_.each MC.canvas_data.component, (compObj) ->
				if compObj.type is constant.RESTYPE.INSTANCE or
					compObj.type is constant.RESTYPE.LC
						imageId = compObj.resource.ImageId
						instanceId = ''
						if compObj.type is constant.RESTYPE.INSTANCE
							instanceId = compObj.resource.InstanceId
						else if compObj.type is constant.RESTYPE.LC
							instanceId = compObj.resource.LaunchConfigurationARN
						if imageId and (not instanceId)
							if not instanceAMIMap[imageId]
								instanceAMIMap[imageId] = []
								amiAry.push imageId
							instanceAMIMap[imageId].push(compObj.uid)
				null

			# get ami info from aws
			if amiAry.length

				currentRegion = MC.canvas_data.region
				amiService.DescribeImages {sender: this},
					$.cookie( 'usercode' ),
					$.cookie( 'session_id' ),
					currentRegion, amiAry, null, null, null, (result) ->

						tipInfoAry = []

						if result.is_error and result.aws_error_code is 'InvalidAMIID.NotFound'
							# get current stack all aws ami
							awsAMIIdAryStr = result.error_message
							awsAMIIdAryStr = awsAMIIdAryStr.replace("The image ids '[", "").replace("]' do not exist", "")
							.replace("The image id '[", "").replace("]' does not exist", "")

							awsAMIIdAry = awsAMIIdAryStr.split(',')
							awsAMIIdAry = _.map awsAMIIdAry, (awsAMIId) ->
								return $.trim(awsAMIId)

							if not awsAMIIdAry.length
								callback(null)
								return null

							_.each amiAry, (amiId) ->
								if amiId in awsAMIIdAry
									# not exist in stack
									instanceUIDAry = instanceAMIMap[amiId]
									_.each instanceUIDAry, (instanceUID) ->
										instanceObj = MC.canvas_data.component[instanceUID]
										instanceType = instanceObj.type
										instanceName = instanceObj.name

										infoObjType = 'Instance'
										infoTagType = 'instance'
										if instanceType is constant.RESTYPE.LC
											infoObjType = 'Launch Configuration'
											infoTagType = 'lc'
										tipInfo = sprintf lang.ide.TA_MSG_ERROR_STACK_HAVE_NOT_EXIST_AMI, infoObjType, infoTagType, instanceName, amiId
										tipInfoAry.push({
											level: constant.TA.ERROR,
											info: tipInfo,
											uid: instanceUID
										})
										null
								null

						else if not result.is_error
							descAMIIdAry = []
							descAMIAry = result.resolved_data
							if _.isArray descAMIAry
								_.each descAMIAry, (amiObj) ->
									descAMIIdAry.push(amiObj.imageId)
									null
							_.each amiAry, (amiId) ->
								if amiId not in descAMIIdAry
									# not exist in stack
									instanceUIDAry = instanceAMIMap[amiId]
									_.each instanceUIDAry, (instanceUID) ->
										instanceObj = MC.canvas_data.component[instanceUID]
										instanceType = instanceObj.type
										instanceName = instanceObj.name

										infoObjType = 'Instance'
										infoTagType = 'instance'
										if instanceType is constant.RESTYPE.LC
											infoObjType = 'Launch Configuration'
											infoTagType = 'lc'
										tipInfo = sprintf lang.ide.TA_MSG_ERROR_STACK_HAVE_NOT_AUTHED_AMI, infoObjType, infoTagType, instanceName, amiId
										tipInfoAry.push({
											level: constant.TA.ERROR,
											info: tipInfo,
											uid: instanceUID
										})
										null
								null

						# return error valid result
						if tipInfoAry.length
							callback(tipInfoAry)
							console.log(tipInfoAry)
						else
							callback(null)

				return null

			else
				callback(null)
		catch err
			callback(null)

	isHaveNotExistAMI = () ->

		# get current all using ami
		amiAry = []
		instanceAMIMap = {}
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.RESTYPE.INSTANCE or
				compObj.type is constant.RESTYPE.LC
					imageId = compObj.resource.ImageId
					instanceId = ''
					if compObj.type is constant.RESTYPE.INSTANCE
						instanceId = compObj.resource.InstanceId
					else if compObj.type is constant.RESTYPE.LC
						instanceId = compObj.resource.LaunchConfigurationARN
					if imageId and (not instanceId)
						if not instanceAMIMap[imageId]
							instanceAMIMap[imageId] = []
							amiAry.push imageId
						instanceAMIMap[imageId].push(compObj.uid)
			null

		awsAMIIdAry = []
		_.each MC.data.dict_ami, (amiObj) ->
			amiId = amiObj.imageId
			awsAMIIdAry.push(amiId)
			null

		tipInfoAry = []

		_.each amiAry, (amiId) ->
			if amiId not in awsAMIIdAry
				# not exist in stack
				instanceUIDAry = instanceAMIMap[amiId]
				_.each instanceUIDAry, (instanceUID) ->
					instanceObj = MC.canvas_data.component[instanceUID]
					instanceType = instanceObj.type
					instanceName = instanceObj.name

					infoObjType = 'Instance'
					infoTagType = 'instance'
					if instanceType is constant.RESTYPE.LC
						infoObjType = 'Launch Configuration'
						infoTagType = 'lc'
					tipInfo = sprintf lang.ide.TA_MSG_ERROR_STACK_HAVE_NOT_EXIST_AMI, infoObjType, infoTagType, instanceName, amiId
					tipInfoAry.push({
						level: constant.TA.ERROR,
						info: tipInfo,
						uid: instanceUID
					})
					null
			null

		return tipInfoAry

	isHaveNotExistAMIAsync : isHaveNotExistAMIAsync
	isHaveNotExistAMI : isHaveNotExistAMI
	verify : verify
