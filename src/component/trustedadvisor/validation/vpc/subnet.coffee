define [ 'constant', 'jquery', 'MC','i18n!nls/lang.js', 'eni_service' , '../result_vo' ], ( constant, $, MC, lang, eniService ) ->

	getAllAWSENIForAppEdit = (callback) ->

		try
			if !callback
				callback = () ->

			currentState = MC.canvas.getState()
			if currentState isnt 'appedit'
				callback(null)
				return null

			currentVPCUID = MC.aws.vpc.getVPCUID()
			currentVPCComp = MC.canvas_data.component[currentVPCUID]
			currentVPCId = currentVPCComp.resource.VpcId

			currentRegion = MC.canvas_data.region
			eniService.DescribeNetworkInterfaces {sender: this},
				$.cookie( 'usercode' ),
				$.cookie( 'session_id' ),
				currentRegion,  [], null, (result) ->

					checkResult = true
					conflictInfo = null

					if !result.is_error
						# get current aws all cgw
						eniObjAry = result.resolved_data
						_.each eniObjAry, (eniObj) ->
							MC.data.resource_list[currentRegion][eniObj.networkInterfaceId] = eniObj
							null
						callback(null)
					else
						callback(null)

			return null

		catch err
			callback(null)

	getAllAWSENIForAppEdit : getAllAWSENIForAppEdit
