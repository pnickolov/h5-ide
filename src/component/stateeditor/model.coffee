#############################
#  View Mode for component/stateeditor
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC',
		 './component/stateeditor/lib/data'
], () ->

	StateEditorModel = Backbone.Model.extend {

		defaults: {
			cmdParaMap: null,
			compData: null,
			allCompData: null
		},

		initialize: () ->

			that = this

			platformInfo = that.getResPlatformInfo()
			osPlatform = platformInfo.osPlatform
			osPlatformDistro = platformInfo.osPlatformDistro

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
			that.genResAttrAndStateList(allCompData)

			# for view
			that.set('cmdParaMap', cmdParaMap)
			that.set('cmdParaObjMap', cmdParaObjMap)
			that.set('cmdModuleMap', cmdModuleMap)
			that.set('moduleCMDMap', moduleCMDMap)

		genResAttrAndStateList: (compData) ->

			that = this

			compList = _.values(compData)
			resAttrDataAry = []
			resStateDataAry = []

			if compList and not _.isEmpty(compList) and _.isArray(compList)

				_.each compList, (compObj) ->

					compName = compObj.name
					
					# find all attr
					keyList = _.keys(compObj.resource)
					if keyList and not _.isEmpty(keyList) and _.isArray(keyList) and not _.isEmpty(compName)
						_.each keyList, (attrName) ->
							completeStr = '{' + compName + '.' + attrName + '}'
							resAttrDataAry.push({
								name: completeStr,
								value: completeStr
							})
						null

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

			that.set('resAttrDataAry', resAttrDataAry)
			that.set('resStateDataAry', resStateDataAry)

		getResPlatformInfo: () ->

			that = this
			compData = that.get('compData')
			imageId = resource.ImageId
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

		setStateData: (stateData) ->

			that = this
			compData = that.get('compData')
			compData.state = stateData

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
	}

	return StateEditorModel