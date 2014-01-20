#############################
#  View Mode for component/stateeditor
#############################

define [ 'MC', 'constant', 'state_model', 'backbone', 'jquery', 'underscore' ], (MC, constant, state_model) ->

	StateEditorModel = Backbone.Model.extend {

		defaults: {
			compData: null,
			allCompData: null,
			stateLogDataAry: []
		},

		initialize: () ->

			that = this

			moduleDataObj = MC.data.state.module

			platformInfo = that.getResPlatformInfo()
			osPlatform = platformInfo.osPlatform
			osPlatformDistro = platformInfo.osPlatformDistro

			if osPlatformDistro
				that.set('supportedPlatform', true)
			else
				that.set('supportedPlatform', false)

			moduleData = {}

			if osPlatform is 'linux'
				moduleData = moduleDataObj.linux
			else if osPlatform is 'windows'
				moduleData = moduleDataObj.windows

			moduleData = _.extend(moduleData, moduleDataObj.general)

			# generate module autocomplete data
			cmdAry = []
			cmdParaMap = {}
			cmdParaObjMap = {}
			cmdModuleMap = {}
			moduleCMDMap = {}

			_.each moduleData, (cmdObj, cmdName) ->

				# get command name
				cmdDistroAry = cmdObj.distro

				if not ((not cmdDistroAry) or (cmdDistroAry and osPlatformDistro in cmdDistroAry))
					return

				cmdAry.push cmdName
				paraAryObj = cmdObj.parameter
				cmdParaMap[cmdName] = []
				cmdParaObjMap[cmdName] = {}
				cmdModuleMap[cmdName] = cmdObj
				moduleCMDMap[cmdObj.module] = cmdName

				# get parameter array
				_.each paraAryObj, (paraObj, paraName) ->
					paraBuildObj = _.extend paraObj, {}
					paraBuildObj.name = paraName
					paraBuildObj['type_' + paraBuildObj.type] = true
					cmdParaMap[cmdName].push paraBuildObj
					cmdParaObjMap[cmdName][paraName] = paraBuildObj
					null

				# sort parameter array
				cmdAllParaAry = cmdParaMap[cmdName]
				cmdParaMap[cmdName] = cmdAllParaAry.sort (paraObj1, paraObj2) ->

					if paraObj1.required and not paraObj2.required
						return false

					if paraObj1.required is paraObj2.required and paraObj1.required is false
						if paraObj1.name < paraObj2.name
							return false

					return true
				null

			cmdAry = cmdAry.sort (val1, val2) ->
				return val1 < val2
			cmdAry = cmdAry.reverse()

			# generate resource attr autocomplete data
			allCompData = that.get('allCompData')

			that.genStateRefList(allCompData)
			that.genAttrRefList(allCompData)

			# for view
			that.set('cmdParaMap', cmdParaMap)
			that.set('cmdParaObjMap', cmdParaObjMap)
			that.set('cmdModuleMap', cmdModuleMap)
			that.set('moduleCMDMap', moduleCMDMap)

			groupResSelectData = that.getGroupResSelectData()
			that.set('groupResSelectData', groupResSelectData)

			# Diffrent view
			currentState = MC.canvas.getState()
			if currentState is 'stack'
				that.set('currentState', 'stack')
			else if currentState is 'app'
				that.set('currentState', 'app')
			else if currentState is 'appedit'
				that.set('currentState', 'appedit')

			if MC.canvas_data.state is 'Stoped'
				that.set('currentAppState', 'stoped')

		getResPlatformInfo: () ->

			that = this
			compData = that.get('compData')
			imageId = compData.resource.ImageId
			imageObj = MC.data.dict_ami[imageId]

			osPlatform = null
			osPlatformDistro = null

			if imageObj

				osFamily = imageObj.osFamily
				osType = imageObj.osType

				linuxDistroRange = ['centos', 'redhat',  'rhel', 'ubuntu', 'debian', 'fedora', 'gentoo', 'opensuse', 'suse', 'sles', 'amazon', 'amaz', 'linux-other']
				
				if osType is 'windows'
					osPlatform = 'windows'
				else if osType in linuxDistroRange
					osPlatform = 'linux'
					osPlatformDistro = osType

			return {
				osPlatform: osPlatform,
				osPlatformDistro: osPlatformDistro
			}

		updateAllStateRef: (newOldStateIdMap) ->

			that = this

			# update
			allCompData = Design.instance().serialize().component
			that.set('allCompData', allCompData)

			oldRef = that.replaceParaNameToUID(originOldRef)
			newRef = that.replaceParaNameToUID(originNewRef)

			allCompData = that.get('allCompData')
			moduleCMDMap = that.get('moduleCMDMap')
			cmdParaObjMap = that.get('cmdParaObjMap')
			_.each allCompData, (compObj) ->
				stateObj = compObj.state
				compUID = compObj.uid
				resModel = Design.instance().component(compUID)
				if stateObj and stateObj.length > 0
					_.each stateObj, (stateItemObj) ->
						paraObj = stateItemObj.parameter
						moduleName = stateItemObj.module
						cmdName = moduleCMDMap[moduleName]
						if not cmdName then return
						paraModelObj = cmdParaObjMap[cmdName]
						if not paraModelObj then return
						_.each paraObj, (paraValue, paraName) ->
							paraType = paraModelObj[paraName]['type']
							if paraType is 'state'
								newParaValue = _.map paraValue, (stateRef) ->
									if newOldStateIdMap[stateRef]
										return newOldStateIdMap[stateRef]
									return stateRef
								paraObj[paraName] = newParaValue
							null
						null
					resModel.setStateData(stateObj)
				null
			null

		setStateData: (stateData) ->

			that = this
			compData = that.get('compData')
			resModel = that.get('resModel')
			resModel.setStateData(stateData)
			MC.canvas.event.nodeState(compData.uid)

		getStateData: () ->

			that = this
			compData = that.get('compData')
			resModel = that.get('resModel')
			if compData
				stateData = resModel.getStateData()
				if _.isArray(stateData)
					return stateData

			return null

		getResName: () ->

			that = this
			compData = that.get('compData')
			if compData and compData.name
				return compData.name
			return ''

		genStateRefList: (allCompData) ->

			that = this

			compList = _.values(allCompData)
			resStateDataAry = []

			compData = that.get('compData')
			currentCompUID = compData.uid

			if compList and not _.isEmpty(compList) and _.isArray(compList)

				_.each compList, (compObj) ->

					compUID = compObj.uid

					if currentCompUID is compUID
						return

					compName = compObj.name

					# find all state
					stateAry = compObj.state
					if stateAry and _.isArray(stateAry)
						_.each stateAry, (stateObj, idx) ->
							stateNumStr = String(idx + 1)
							stateRefStr = '{' + compName + '.state.' + stateNumStr + '}'
							resStateDataAry.push({
								name: stateRefStr,
								value: stateRefStr
							})

					null

			that.set('resStateDataAry', resStateDataAry)

		genAttrRefList: (allCompData) ->

			that = this

			autoCompList = []

			awsPropertyData = MC.data.state.aws_property

			# compTypeMap = constant.AWS_RESOURCE_TYPE

			_.each allCompData, (compData, uid) ->

				compName = compData.name
				compUID = compData.uid
				compType = compData.type

				# replace instance default eni name to instance name
				if compType is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
					if compData.resource.Attachment.DeviceIndex in ['0', 0]
						return
						# instanceRef = compData.resource.Attachment.InstanceId
						# if instanceRef
						# 	instanceUID = MC.extractID(instanceRef)
						# 	if instanceUID
						# 		compName = allCompData[instanceUID].name

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

						autoCompList.push({
							name: autoCompStr,
							value: autoCompRefStr
						})

						if isArray

							if supportType is 'AWS_AutoScaling_Group'
								if attrName in ['AvailabilityZones']
									azAry = compData.resource.AvailabilityZones
									if azAry.length > 1
										_.each azAry, (azName, idx) ->
											autoCompList.push({
												name: autoCompStr + '[' + idx + ']',
												value: autoCompRefStr + '[' + idx + ']'
											})
											null

							if supportType is 'AWS_VPC_NetworkInterface'
								if attrName in ['PublicDnsName', 'PublicIp', 'PrivateDnsName', 'PrivateIpAddress']
									ipObjAry = compData.resource.PrivateIpAddressSet
									if ipObjAry.length > 1
										_.each ipObjAry, (ipObj, idx) ->
											autoCompList.push({
												name: autoCompStr + '[' + idx + ']',
												value: autoCompRefStr + '[' + idx + ']'
											})
											null

							if supportType is 'AWS_ELB'
								if attrName in ['AvailabilityZones']
									azAry = compData.resource.AvailabilityZones
									if azAry.length > 1
										_.each azAry, (azName, idx) ->
											autoCompList.push({
												name: autoCompStr + '[' + idx + ']',
												value: autoCompRefStr + '[' + idx + ']'
											})
											null

						null

				null

			resAttrDataAry = _.map autoCompList, (autoCompObj) ->
				return {
					name: "{#{autoCompObj.name}}"
					value: "{#{autoCompObj.name}}"
				}
			that.set('resAttrDataAry', resAttrDataAry)

		replaceParaUIDToName: (paraValue) ->

			that = this

			allCompData = that.get('allCompData')

			refRegex = /@\{([A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12})(\.(\w+(\[\d+\])*))+\}/g
			uidRegex = /[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}/
			refMatchAry = paraValue.match(refRegex)

			newParaValue = paraValue

			_.each refMatchAry, (refMatchStr) ->

				uidMatchAry = refMatchStr.match(/[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}/)
				resUID = uidMatchAry[0]
				if allCompData[resUID]
					resName = allCompData[resUID].name
					newRefStr = refMatchStr.replace(resUID, resName)
					newParaValue = newParaValue.replace(refMatchStr, newRefStr)

				null

			return newParaValue

		replaceParaNameToUID: (paraValue) ->

			that = this

			allCompData = that.get('allCompData')

			refRegex = /@\{(\w|\-)+(\.(\w+(\[\d+\])*))+\}/g
			refMatchAry = paraValue.match(refRegex)

			newParaValue = paraValue

			_.each refMatchAry, (refMatchStr) ->

				resName = refMatchStr.replace('@{', '').split('.')[0]
				resUID = that.getUIDByResName(resName)
				if resUID
					newUIDStr = refMatchStr.replace(resName, resUID)
					newParaValue = newParaValue.replace(refMatchStr, newUIDStr)
				null

			return newParaValue

		getUIDByResName: (resName) ->

			that = this
			allCompData = that.get('allCompData')
			resultUID = ''
			_.each allCompData, (resObj, uid) ->
				if resObj.name is resName
					resultUID = uid
				null
			return resultUID

		genStateLogData: (res_id, callback) ->

			that = this

			appId = MC.canvas_data.id
			resId = res_id

			if not (appId and resId)

				that.set('stateLogDataAry', [])
				callback()
				return

			state_model.log { sender : that }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), appId, resId

			that.on 'STATE_LOG_RETURN', ( result ) ->

				if !result.is_error

					statusDataAry = result.resolved_data

					if statusDataAry and statusDataAry[0]

						statusObj = statusDataAry[0]

						logAry = statusObj.statuses

						if not (logAry and _.isArray(logAry))
							logAry = []

						that.set('stateLogDataAry', logAry)

						if callback

							callback()

		getCurrentResUID: () ->

			that = this
			compData = that.get('compData')
			currentCompUID = compData.uid
			return currentCompUID

		getGroupResSelectData: () ->

			that = this
			compData = that.get('compData')
			allCompData = that.get('allCompData')

			originGroupUID = ''
			originCompUID = compData.uid
			if compData.type is 'AWS.EC2.Instance'
				originGroupUID = compData.serverGroupUid

			dataAry = []

			_.each allCompData, (compObj) ->

				compType = compObj.type
				compUID = compObj.uid

				if compType is 'AWS.EC2.Instance' and compData.type is compType

					currentGroupUID = compObj.serverGroupUid

					if compUID is originCompUID
						resId = compObj.resource.InstanceId

						# resName = compObj.serverGroupName
						# if not resName
						resName = compObj.name

						dataAry.push({
							res_id: resId,
							res_name: resName
						})
					else if (originGroupUID and currentGroupUID and compUID isnt originGroupUID and currentGroupUID is originGroupUID)
						resId = compObj.resource.InstanceId
						dataAry.push({
							res_id: resId,
							res_name: compObj.name
						})
				null

				if compType is 'AWS.AutoScaling.Group' and compData.type is 'AWS.AutoScaling.LaunchConfiguration'

					asgName = compObj.resource.AutoScalingGroupName
					lsgUID = MC.extractID(compObj.resource.LaunchConfigurationName)

					if lsgUID is originCompUID

						# find asg name's all instance
						$.each MC.data.resource_list[MC.canvas_data.region], (idx, resObj) ->
							if resObj and resObj.AutoScalingGroupName and resObj.Instances
								if resObj.AutoScalingGroupName is asgName
									$.each resObj.Instances.member, (idx, instanceObj) ->
										instanceId = instanceObj.InstanceId
										dataAry.push({
											res_id: instanceId,
											res_name: instanceId
										})

				null

			# console.log(dataAry)

			return dataAry
	}

	return StateEditorModel