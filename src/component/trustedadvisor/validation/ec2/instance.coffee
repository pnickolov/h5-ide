define [ 'constant', 'MC', '../result_vo' ], ( constant, MC, resultVO ) ->

	checkValue = ( uid ) ->

		instanceObj = MC.canvas_data.component[uid]
		instanceName = instanceObj.name

		resultVO.set resultVO.WARNING, "The instance #{instanceName} need have a suitable EIP", uid

	checkValue : checkValue