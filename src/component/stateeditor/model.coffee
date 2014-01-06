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

			# generate module autocomplete data
			cmdAry = []
			cmdParaMap = {}
			cmdParaObjMap = {}
			cmdModuleMap = {}
			moduleCMDMap = {}

			moduleData = data.linux

			moduleData = _.extend(moduleData, data.general)

			_.each moduleData, (cmdObj, cmdName) ->

				# get command name
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
			resAttrDataAry = that.genResAttrList(allCompData)

			# for view
			that.set('cmdParaMap', cmdParaMap)
			that.set('cmdParaObjMap', cmdParaObjMap)
			that.set('cmdModuleMap', cmdModuleMap)
			that.set('moduleCMDMap', moduleCMDMap)
			that.set('resAttrDataAry', resAttrDataAry)

		genResAttrList: (compData) ->

			compList = _.values(compData)
			resultAry = []
			if compList and not _.isEmpty(compList) and _.isArray(compList)
				_.each compList, (compObj) ->
					compName = compObj.name
					keyList = _.keys(compObj.resource)
					if keyList and not _.isEmpty(keyList) and _.isArray(keyList) and not _.isEmpty(compName)
						_.each keyList, (attrName) ->
							completeStr = '{' + compName + '.' + attrName + '}'
							resultAry.push({
								name: completeStr,
								value: completeStr
							})
						null
					null

			return resultAry

	}

	return StateEditorModel