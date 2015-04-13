define [ 'constant', 'jquery', 'MC','i18n!/nls/lang.js', 'TaHelper' ], ( constant, $, MC, lang, Helper ) ->

	getAllAWSENIForAppEditAndDefaultVPC : (callback) -> callback(null)

	isCidrConflict: () ->

		Model = Design.modelClassForType(constant.RESTYPE.SUBNET)
		subnets = Model.allObjects()
		results = []
		subnets.sort (sb1, sb2) ->
			conflict = Model.isCidrConflict(sb1.get("cidr"), sb2.get("cidr"))
			if conflict
				results.push(Helper.message.error null, lang.TA.ERROR_CIDR_CONFLICT,
					sb1.get('name'), sb1.get('cidr'), sb2.get('name'), sb2.get('cidr'))
		return results
