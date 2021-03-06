#############################
#  View Mode for component/stateeditor
#############################

define [ 'MC', 'constant', 'CloudResources', "Design", "ApiRequest", "OpsModel", 'backbone', 'jquery', 'underscore' ], (MC, constant, CloudResources, Design, ApiRequest, OpsModel ) ->

	StateEditorModel = Backbone.Model.extend {

		defaults: {
			compData: null,
			allCompData: null,
			stateLogDataAry: []
		},

		initialize: (options) ->

			that = this

			resUID = options.resUID

			resModel = Design.instance().component(resUID)

			if resModel and resModel.isMesos and resModel.isMesos()
				resModel.setMesosState()

			return if not (resModel and resModel.serialize)

			resId = options.resId or resModel.get('appId')
			allCompData = Design.instance().serialize().component
			compData = allCompData[resUID]

			that.set({
				resModel: resModel,
				resId: resId,
				compData: compData,
				allCompData: allCompData
			})

			stateModuel = Design.instance().get('agent').module
			moduleDataObj = App.model.getStateModule( stateModuel.repo, stateModuel.tag )

			platformInfo = that.getResPlatformInfo()
			osPlatform = platformInfo.osPlatform
			osPlatformDistro = platformInfo.osPlatformDistro

			if osPlatform is 'windows'
				that.set('isWindowsPlatform', true)
			else
				that.set('isWindowsPlatform', false)

			# osType = (resModel.getAmi() || resModel.get("cachedAmi")).osType
			# if osType is 'windows'
			if osPlatformDistro is 'windows'
				that.set('isWindowsPlatform', true)

			that.set('amiExist', platformInfo.amiExist)

			if osPlatformDistro
				that.set('supportedPlatform', true)
			else
				that.set('supportedPlatform', false)

			moduleData = {}

			if osPlatform is 'linux' or not osPlatformDistro
				moduleData = _.extend(moduleData, moduleDataObj.linux) if moduleDataObj.linux
			else if osPlatform is 'windows'
				moduleData = _.extend(moduleData, moduleDataObj.windows) if moduleDataObj.windows

			moduleData = _.extend(moduleData, moduleDataObj.common) if moduleDataObj.common
			moduleData = _.extend(moduleData, moduleDataObj.meta) if moduleDataObj.meta

			# generate module autocomplete data
			cmdAry = []
			cmdParaMap = {}
			cmdParaObjMap = {}
			cmdModuleMap = {}
			moduleCMDMap = {}

			_.each moduleData, (cmdObj, cmdName) ->

				# get command name
				cmdDistroAry = cmdObj.distro

				supportCMD = false
				if ((not cmdDistroAry) or (cmdDistroAry and osPlatformDistro in cmdDistroAry)) and osPlatform is 'linux'
					supportCMD = true

				if not osPlatformDistro
					supportCMD = true

				cmdObj.support = supportCMD

				cmdAry.push({
					name: cmdName,
					support: supportCMD
				})
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
				cmdParaMap[cmdName] = that.sortParaList(cmdAllParaAry, 'name')
				null

			cmdNameAry = cmdAry.sort (val1, val2) ->

				if val1.support is val2.support

					if val1.name > val2.name
						return 1
					else if val1.name < val2.name
						return -1
					else
						return 0

				else

					if val1.support is true then return -1
					if val2.support is true then return 1

			# generate resource attr autocomplete data
			allCompData = that.get('allCompData')

			# for view
			that.set('cmdNameAry', cmdNameAry)
			that.set('cmdParaMap', cmdParaMap)
			that.set('cmdParaObjMap', cmdParaObjMap)
			that.set('cmdModuleMap', cmdModuleMap)
			that.set('moduleCMDMap', moduleCMDMap)

			that.genStateRefList(allCompData)

			resAttrDataAry = MC.aws.aws.genAttrRefList(compData, allCompData)
			that.set('resAttrDataAry', resAttrDataAry)

			that.genResAttrDataMap()

			that.genAttrRefRegexList()

			groupResSelectData = that.getGroupResSelectData()
			that.set('groupResSelectData', groupResSelectData)

			# Diffrent view
			that.set('currentState', Design.instance().mode())

		genResAttrDataMap: () ->

			nameToUIDRefMap = {}
			uidToNameRefMap = {}
			resAttrDataAry = @get('resAttrDataAry')
			_.each resAttrDataAry, (data) ->
				nameToUIDRefMap["@{#{data.name}}"] = "@{#{data.uid}}"
				uidToNameRefMap["@{#{data.uid}}"] = "@{#{data.name}}"
			@set('nameToUIDRefMap', nameToUIDRefMap)
			@set('uidToNameRefMap', uidToNameRefMap)

		sortParaList: (cmdAllParaAry, paraName) ->

			newCMDAllParaAry = cmdAllParaAry.sort (paraObj1, paraObj2) ->

				if paraObj1.required is paraObj2.required
					if paraObj1[paraName] < paraObj2[paraName]
						return -1
					else
						return 1

				if paraObj1.required
					return -1

				if paraObj2.required
					return 1

			return newCMDAllParaAry

		getResPlatformInfo: () ->

			that = this

			resModel = that.get('resModel')
			imageId = resModel.get('imageId')

			isAWSAMI = true
			isAWSAMI = false if resModel.type is constant.RESTYPE.OSSERVER

			if isAWSAMI
				imageObj = CloudResources(Design.instance().credentialId(), constant.RESTYPE.AMI, Design.instance().region()).get(imageId)
			else
				imageObj = CloudResources(Design.instance().credentialId(), constant.RESTYPE.OSIMAGE, Design.instance().region()).get(imageId)

			osPlatform = null
			osPlatformDistro = null

			amiExist = true

			layoutOSType = ''
			cachedAmi = resModel.get('cachedAmi')
			layoutOSType = cachedAmi.osType if cachedAmi

			if imageObj

				if isAWSAMI
					osType = imageObj.get('osType') or layoutOSType
				else
					osType = imageObj.get('os_type')

				# linuxDistroRange = ['centos', 'redhat',  'rhel', 'ubuntu', 'debian', 'fedora', 'gentoo', 'opensuse', 'suse', 'sles', 'amazon', 'amaz']
				linuxDistroRange = ['centos', 'redhat', 'ubuntu', 'rhel', 'debian', 'amazon', 'amaz']

				if osType is 'windows'
					osPlatform = 'windows'
				else if osType in linuxDistroRange
					osPlatform = 'linux'
					osPlatformDistro = osType
				else if layoutOSType in linuxDistroRange
					osPlatform = 'linux'
					osPlatformDistro = layoutOSType

			else

				amiExist = false

			return {
				osPlatform: osPlatform,
				osPlatformDistro: osPlatformDistro,
				amiExist: amiExist
			}

		updateAllStateRef: (newOldStateIdMap) ->

			that = this

			allInstanceModel =  Design.modelClassForType(constant.RESTYPE.INSTANCE).allObjects()
			allLCModel =  Design.modelClassForType(constant.RESTYPE.LC).allObjects()

			newOldStateIdRefMap = {}
			_.each newOldStateIdMap, (value, key) ->
				newKey = that.replaceParaNameToUID(key)
				newValue = that.replaceParaNameToUID(value)
				newOldStateIdRefMap[newKey] = newValue
				null

			moduleCMDMap = that.get('moduleCMDMap')
			cmdParaObjMap = that.get('cmdParaObjMap')

			dealFunc = (resModel) ->

				stateObj = resModel.getStateData()
				compUID = resModel.id
				if stateObj and stateObj.length > 0
					_.each stateObj, (stateItemObj) ->
						paraObj = stateItemObj.parameter
						moduleName = stateItemObj.module
						cmdName = moduleCMDMap[moduleName]
						if not cmdName then return
						paraModelObj = cmdParaObjMap[cmdName]
						if not paraModelObj then return
						_.each paraObj, (paraValue, paraName) ->
							paraType = paraModelObj[paraName].type
							if paraType is 'state'
								newParaValue = _.map paraValue, (stateRef) ->
									if newOldStateIdRefMap[stateRef]
										return newOldStateIdRefMap[stateRef]
									return stateRef
								paraObj[paraName] = newParaValue
							null
						null
					resModel.setStateData(stateObj)
				null

			_.each allInstanceModel, dealFunc
			_.each allLCModel, dealFunc

			null

		setStateData: (stateData) ->

			that = this
			resModel = that.get('resModel')
			resModel.setStateData(stateData)

		getStateData: () ->

			that = this
			resModel = that.get('resModel')

			return null if not (resModel and resModel.getStateData)

			stateData = resModel.getStateData()
			if _.isArray(stateData)
				return stateData

			return null

		getResName: () ->

			that = this
			resName = ''
			compData = that.get('compData')
			if compData and compData.name
				resName = compData.name
			if compData.type is constant.RESTYPE.INSTANCE
				if compData.serverGroupUid is compData.uid
					if compData.serverGroupName
						resName = compData.serverGroupName
			return resName

		genStateRefList: (allCompData) ->

			that = this

			compList = _.values(allCompData)
			resStateDataAry = []

			compData = that.get('compData')
			currentCompUID = compData.uid

			moduleCMDMap = that.get('moduleCMDMap')

			if compList and not _.isEmpty(compList) and _.isArray(compList)

				_.each compList, (compObj) ->

					compUID = compObj.uid
					compType = compObj.type
					compName = compObj.name

					if currentCompUID is compUID
						return

					if compType is constant.RESTYPE.INSTANCE
						if compObj.index isnt 0
							return
						compName = compObj.serverGroupName

					if compType is constant.RESTYPE.ASG
						compName = compObj.name
						lcUID = MC.extractID(compObj.resource.LaunchConfigurationName)
						compObj = allCompData[lcUID] if lcUID

					# find all state
					stateAry = compObj.state
					if stateAry and _.isArray(stateAry)
						_.each stateAry, (stateObj, idx) ->
							if stateObj.module isnt 'meta.comment'
								stateNumStr = String(idx + 1)
								stateRefStr = '{' + compName + '.state.' + stateNumStr + '}'
								stateMeta = moduleCMDMap[stateObj.module]
								resStateDataAry.push({
									name: stateRefStr,
									value: stateRefStr,
									meta: stateMeta
								})

					null

			resStateDataAry = resStateDataAry.sort (val1, val2) ->

				if val1.name > val2.name
					return 1
				else if val1.name < val2.name
					return -1
				else
					return 0

			that.set('resStateDataAry', resStateDataAry)

		genAttrRefRegexList: () ->

			that = this
			attrRefRegexList = []
			resAttrDataAry = that.get('resAttrDataAry')
			resStateDataAry = that.get('resStateDataAry')
			if not resAttrDataAry then resAttrDataAry = []

			attrRefRegexList = _.map resAttrDataAry, (refObj) ->
				regStr = refObj.name.replace('{', '\\{').replace('}', '\\}').replace('.', '\\.').replace('[', '\\[').replace(']', '\\]')
				return '@' + '{' + regStr + '}'
			stateRefRegexList = _.map resStateDataAry, (refObj) ->
				regStr = refObj.name.replace('{', '\\{').replace('}', '\\}').replace('.', '\\.').replace('[', '\\[').replace(']', '\\]')
				return '@' + regStr

			attrRefRegexList = attrRefRegexList.concat(stateRefRegexList)

			resAttrRegexStr = attrRefRegexList.join('|')
			that.set('resAttrRegexStr', resAttrRegexStr)

		# @{uuid.state.state-uuid}
		replaceStateUIDToName: (paraValue) ->

			that = this

			allCompData = that.get('allCompData')

			refRegex = /@\{([A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12})\.state\.state-([A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12})\}/g
			uidRegex = /[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}/g
			refMatchAry = paraValue.match(refRegex)

			newParaValue = paraValue

			if refMatchAry and refMatchAry.length

				refMatchStr = refMatchAry[0]
				uidMatchAry = refMatchStr.match(uidRegex)
				resUID = uidMatchAry[0]
				stateUID = 'state-' + uidMatchAry[1]

				compData = allCompData[resUID]
				resName = 'unknown'
				stateNum = 'unknown'

				if compData
					stateNumMap = {}

					resName = compData.name
					if compData.type is constant.RESTYPE.INSTANCE
						if compData.number and compData.number > 1
							resName = compData.serverGroupName

					if compData.type is constant.RESTYPE.LC
						_.each allCompData, (asgCompData) ->
							if asgCompData.type is constant.RESTYPE.ASG
								lcUIDRef = asgCompData.resource.LaunchConfigurationName
								if lcUIDRef
									lcUID = MC.extractID(lcUIDRef)
									if lcUID is resUID
										resName = asgCompData.name
							null

					# if compData.type is constant.RESTYPE.ASG
					# 	lcUIDRef = compData.resource.LaunchConfigurationName
					# 	if lcUIDRef
					# 		lcUID = MC.extractID(lcUIDRef)
					# 		lcCompData = allCompData[lcUID]
					# 		if lcCompData then compData = lcCompData

					if compData.state and _.isArray compData.state
						_.each compData.state, (stateObj, idx) ->
							if stateObj.id is stateUID
								stateNum = idx + 1
							null

				newRefStr = refMatchStr.replace(resUID, resName).replace(stateUID, stateNum)
				newParaValue = newParaValue.replace(refMatchStr, newRefStr)

			return newParaValue

		replaceStateNameToUID: (paraValue) ->

			that = this

			allCompData = that.get('allCompData')

			refRegex = /@\{([\w-]+)\.state\.\d+\}/g
			refMatchAry = paraValue.match(refRegex)

			newParaValue = paraValue

			if refMatchAry and refMatchAry.length

				refMatchStr = refMatchAry[0]
				resName = refMatchStr.replace('@{', '').split('.')[0]
				resUID = that.getUIDByResName(resName)
				stateNum = Number(refMatchStr.replace('}', '').split('.')[2])
				stateUID = ''

				lcCompData = null
				if resUID and _.isNumber(stateNum)
					compData = allCompData[resUID]

					if compData.type is constant.RESTYPE.ASG
						lcUIDRef = compData.resource.LaunchConfigurationName
						if lcUIDRef
							lcUID = MC.extractID(lcUIDRef)
							resUID = lcUID
							lcCompData = allCompData[lcUID]

					if lcCompData then compData = lcCompData

					if compData.state and _.isArray(compData.state) and compData.state[stateNum - 1]
						stateUID = compData.state[stateNum - 1].id

				if resUID and stateUID
					newUIDStr = refMatchStr.replace(resName, resUID).replace('.state.' + stateNum, '.state.' + stateUID)
					newParaValue = newParaValue.replace(refMatchStr, newUIDStr)

			return newParaValue

		replaceParaUIDToName: (paraValue) ->

			that = this

			currentCompUID = that.get('compData').uid

			allCompData = that.get('allCompData')

			refRegex = /@\{([A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12})(\.(\w+(\[\d+\])*))+\}/g
			uidRegex = /[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}/
			refMatchAry = paraValue.match(refRegex)

			newParaValue = paraValue

			if Design.instance().type() is OpsModel.Type.OpenStack

				# openstack
				_.each refMatchAry, (refMatchStr) ->

					uidMatchAry = refMatchStr.match(uidRegex)
					resUID = uidMatchAry[0]

					uidToNameRefMap = that.get('uidToNameRefMap')
					newRefStr = uidToNameRefMap[refMatchStr]
					if not newRefStr
						newRefStr = refMatchStr.replace(resUID, 'unknown')
					newParaValue = newParaValue.replace(refMatchStr, newRefStr)

			else

				# for aws
				_.each refMatchAry, (refMatchStr) ->

					uidMatchAry = refMatchStr.match(uidRegex)
					resUID = uidMatchAry[0]

					# if resUID is currentCompUID
					# 	resName = 'self'
					# else
					compData = allCompData[resUID]
					if compData
						resName = compData.name
						if compData.type is constant.RESTYPE.INSTANCE
							if compData.number and compData.number > 1
								resName = compData.serverGroupName
					else
						resName = 'unknown'

					newRefStr = refMatchStr.replace(resUID, resName)
					newParaValue = newParaValue.replace(refMatchStr, newRefStr)

					null

			return newParaValue

		replaceParaNameToUID: (paraValue) ->

			that = this

			allCompData = that.get('allCompData')

			refRegex = constant.REGEXP.stateEditorOriginReference
			refMatchAry = paraValue.match(refRegex)

			newParaValue = paraValue

			if Design.instance().type() is OpsModel.Type.OpenStack

				# for open stack
				_.each refMatchAry, (refMatchStr) ->

					resName = refMatchStr.replace('@{', '').split('.')[0]
					if resName isnt 'self'
						nameToUIDRefMap = that.get('nameToUIDRefMap')
						newUIDStr = nameToUIDRefMap[refMatchStr]
						newParaValue = newParaValue.replace(refMatchStr, newUIDStr) if newUIDStr
					null

			else

				# for aws
				_.each refMatchAry, (refMatchStr) ->

					resName = refMatchStr.replace('@{', '').split('.')[0]
					if resName isnt 'self'
						resUID = that.getUIDByResName(resName)
						if resUID
							newUIDStr = refMatchStr.replace(resName, resUID)
							newParaValue = newParaValue.replace(refMatchStr, newUIDStr)
					null

			return newParaValue

		getUIDByResName: (resName) ->

			that = this
			currentCompUID = that.get('compData').uid
			allCompData = that.get('allCompData')

			# if resName is 'self'
			# 	return currentCompUID

			resultUID = ''
			$.each allCompData, (uid, resObj) ->

				if resObj.type is constant.RESTYPE.INSTANCE
					if resObj.number and resObj.number > 1
						if resObj.serverGroupName is resName
							resultUID = uid
							return false

				if resObj.name is resName
					resultUID = uid

				null

			return resultUID

		getResState: (resId) ->

			if Design.instance().type() is OpsModel.Type.Amazon

				resModel = CloudResources(Design.instance().credentialId(), constant.RESTYPE.INSTANCE, Design.instance().region()).get(resId)
				resState = 'unknown'
				if resModel
					resState = resModel.get('instanceState')?.name
				@set('resState', resState)

			else

				resModel = CloudResources(Design.instance().credentialId(), constant.RESTYPE.OSSERVER, Design.instance().region()).get(resId)
				resState = 'unknown'
				if resModel
					resState = resModel.get('status')
				@set('resState', resState)

		genStateLogData: (resId, callback) ->

			that = this

			appId = Design.instance().get('id')

			if not (appId and resId)

				that.set('stateLogDataAry', [])
				callback()
				return

			resModel = that.get('resModel')
			stateDataAry = resModel.getStateData()

			stateIdNumMap = {}
			originStatusDataAry = _.map stateDataAry, (stateObj, idx) ->
				stateIdNumMap[stateObj.id] = idx
				return {
					id: stateObj.id,
					result: 'pending'
				}
			agentStatus = 'pending'

			ApiRequest('state_log', {
				app_id: appId,
				res_id: resId
			}).then (data) ->

				if data

					statusDataAry = data

					if statusDataAry and statusDataAry[0]

						statusObj = statusDataAry[0]

						if statusObj.agent_status
							agentStatus = statusObj.agent_status

						logAry = statusObj.status

						if logAry and _.isArray(logAry)
							_.each logAry, (logObj) ->
								stateNum = stateIdNumMap[logObj.id]
								if _.isNumber(stateNum)
									originStatusDataAry[stateNum] = logObj
								return

					originStatusDataAry.unshift({
						id: 'Agent',
						result: agentStatus
					})

					that.set('stateLogDataAry', originStatusDataAry)
					that.set('agentStatus', agentStatus)

				if callback then callback()

			, (err) ->

				if callback then callback()

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

				if compType is 'AWS.AutoScaling.Group' and compData.type is 'AWS.AutoScaling.LaunchConfiguration'

					asgName = compObj.resource.AutoScalingGroupName
					lsgUID = MC.extractID(compObj.resource.LaunchConfigurationName)

					if lsgUID is originCompUID

						# find asg name's all instance
						$.each CloudResources(Design.instance().credentialId(), constant.RESTYPE.ASG, Design.instance().region()).toJSON(), (idx, resObj) ->
							if resObj and resObj.AutoScalingGroupName and resObj.Instances
								if resObj.AutoScalingGroupName is asgName
									$.each resObj.Instances, (idx, instanceObj) ->
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
