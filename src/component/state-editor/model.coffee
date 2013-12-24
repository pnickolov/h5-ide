StateEditorModel = Backbone.Model.extend({

	defaults: {
		cmdParaMap: null,
		lookupDataAry: null
	},

	initialize: () ->

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

				if paraObj1.required is paraObj2.required
					if paraObj1.name > paraObj1.name
						return false

				return true
			null

		# init command
		cmdAry = cmdAry.sort (val1, val2) ->
			return val1 < val2
		cmdAry = cmdAry.reverse()

		console.log(cmdAry)
		console.log(cmdParaMap)

		lookupDataAry = _.map cmdAry, (elem, idx) ->
			value: elem
			data: elem

		this.set('cmdParaMap', cmdParaMap)
		this.set('cmdParaObjMap', cmdParaObjMap)
		this.set('lookupDataAry', lookupDataAry)
		this.set('cmdModuleMap', cmdModuleMap)
		this.set('moduleCMDMap', moduleCMDMap)
})

window.StateEditorModel = StateEditorModel