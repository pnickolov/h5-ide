define [ 'constant', 'MC', '../result_vo' ], ( constant, MC, result_vo ) ->

	checkValue = ( uid ) ->

		instanceObj = MC.canvas_data.component[uid]
		instanceName = instanceObj.name

		result_vo.set uid, 'warning', "The instance #{instanceName} need have a suitable EIP"

		result_vo.get()

	checkValue : checkValue