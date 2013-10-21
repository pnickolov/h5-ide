define [ 'constant', 'MC' ], ( constant, MC ) ->

	checkValue = ( uid ) ->

		instanceObj = MC.canvas_data.component[uid]
		instanceName = instanceObj.name
		
		result = {
			level: "warn",
			info: "The instance #{instanceName} need have a suitable EIP",
			uid: uid
		}

		result

	checkValue : checkValue