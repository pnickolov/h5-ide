#############################
#  View Mode for component/stateeditor
#############################

define [ 'MC', 'constant', 'backbone', 'jquery', 'underscore',
		 './component/stateeditor/lib/data',
		 './component/stateeditor/lib/data1'
], (MC, constant) ->

	StateEditorModel = Backbone.Model.extend {

		defaults: {
			compData: null,
			allCompData: null
		},

		initialize: () ->

			that = this

			platformInfo = that.getResPlatformInfo()
			osPlatform = platformInfo.osPlatform
			osPlatformDistro = platformInfo.osPlatformDistro

			if osPlatformDistro
				that.set('supportedPlatform', true)
			else
				that.set('supportedPlatform', false)

			moduleData = {}

			if osPlatform is 'linux'
				moduleData = data.linux
			else if osPlatform is 'windows'
				moduleData = data.windows

			moduleData = _.extend(moduleData, data.general)

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

		updateAllStateRef: (oldRef, newRef) ->

			that = this
			allCompData = that.get('allCompData')
			moduleCMDMap = that.get('moduleCMDMap')
			cmdParaObjMap = that.get('cmdParaObjMap')
			_.each allCompData, (compObj) ->
				stateObj = compObj.state
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
									if stateRef is oldRef
										return newRef
									return stateRef
								paraObj[paraName] = newParaValue
							null
						null
				null
			null

		setStateData: (stateData) ->

			that = this
			compData = that.get('compData')
			compData.state = stateData
			MC.canvas.event.nodeState(compData.uid)

		getStateData: () ->

			that = this
			compData = that.get('compData')
			if compData and compData.state
				return compData.state
			return null

		getResName: () ->

			that = this
			compData = that.get('compData')
			if compData and compData.name
				return compData.name
			return ''

		genStateRefList: (compData) ->

			that = this

			compList = _.values(compData)
			resStateDataAry = []

			if compList and not _.isEmpty(compList) and _.isArray(compList)

				_.each compList, (compObj) ->

					compName = compObj.name
					
					# find all attr
					# keyList = _.keys(compObj.resource)
					# if keyList and not _.isEmpty(keyList) and _.isArray(keyList) and not _.isEmpty(compName)
					# 	_.each keyList, (attrName) ->
					# 		completeStr = '{' + compName + '.' + attrName + '}'
					# 		resAttrDataAry.push({
					# 			name: completeStr,
					# 			value: completeStr
					# 		})
					# 	null

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

			compAttrModelObj = data1
			# compTypeMap = constant.AWS_RESOURCE_TYPE

			_.each allCompData, (compData, uid) ->

				compName = compData.name
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
				attrList = compAttrModelObj[supportType]
				if attrList

					_.each attrList, (isArray, attrName) ->

						autoCompStr = (compName + '.') # host1.

						if attrName is '__array'
							return
						else
							autoCompStr += attrName

						autoCompList.push(autoCompStr)

						if isArray

							if supportType is 'AWS_AutoScaling_Group'
								if attrName in ['AvailabilityZones']
									azAry = compData.resource.AvailabilityZones
									if azAry.length > 1
										_.each azAry, (azName, idx) ->
											autoCompList.push(autoCompStr + '[' + idx + ']')
											null

							if supportType is 'AWS_VPC_NetworkInterface'
								if attrName in ['PublicDnsName', 'PublicIp', 'PrivateDnsName', 'PrivateIpAddress']
									ipObjAry = compData.resource.PrivateIpAddressSet
									if ipObjAry.length > 1
										_.each ipObjAry, (ipObj, idx) ->
											autoCompList.push(autoCompStr + '[' + idx + ']')
											null

							if supportType is 'AWS_ELB'
								if attrName in ['AvailabilityZones']
									azAry = compData.resource.AvailabilityZones
									if azAry.length > 1
										_.each azAry, (azName, idx) ->
											autoCompList.push(autoCompStr + '[' + idx + ']')
											null

						null

				null

			resAttrDataAry = _.map autoCompList, (autoCompStr) ->
				attrRef = "{#{autoCompStr}}"
				return {
					name: attrRef,
					value: attrRef
				}
			that.set('resAttrDataAry', resAttrDataAry)

	}

	return StateEditorModel