define [ 'constant', 'jquery', 'MC','i18n!/nls/lang.js', 'ApiRequest', "CloudResources" ], ( constant, $, MC, lang, ApiRequest, CloudResources ) ->

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

						errInfoStr = sprintf lang.TA.ERROR_STACK_FORMAT_VALID_FAILED, errCompName, errMessage

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

						if (errCode is 'EMPTY_VALUE' and
							errKey is 'TopicARN' and
							errMessage is 'Key TopicARN can not empty' and
							errCompType is 'AWS.AutoScaling.NotificationConfiguration')
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
			tipInfo = sprintf lang.TA.ERROR_STACK_CHECKING_FORMAT_VALID
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

			# get current all using ami
			tipInfoAry = []
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
				cr = CloudResources( constant.RESTYPE.AMI, MC.canvas_data.region )

				failure = ()-> callback(null)
				success = ()->
					invalids = []
					for id in amiAry
						if cr.isInvalidAmiId( id )
							invalids.push id

					if not invalids.length then return callback(null)

					for amiId in invalids
						for instanceUID in instanceAMIMap[ amiId ] || []
							instanceObj = MC.canvas_data.component[instanceUID]

							if instanceObj.type is constant.RESTYPE.LC
								infoTagType = 'lc'
							else
								infoTagType = "instance"

							tipInfoAry.push({
								level : constant.TA.ERROR
								uid   : instanceUID
								info  : sprintf lang.TA.ERROR_STACK_HAVE_NOT_EXIST_AMI, instanceObj.type, infoTagType, instanceObj.name, amiId
							})

					if tipInfoAry.length
						callback(tipInfoAry)
						console.log(tipInfoAry)
					else
						callback(null)

				cr.fetchAmis( amiAry ).then success, failure
				return

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

		tipInfoAry = []

		amiCollection = CloudResources( constant.RESTYPE.AMI, MC.canvas_data.region )

		_.each amiAry, (amiId) ->
			if not amiCollection.get( amiId )
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
					tipInfo = sprintf lang.TA.ERROR_STACK_HAVE_NOT_EXIST_AMI, infoObjType, infoTagType, instanceName, amiId
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
