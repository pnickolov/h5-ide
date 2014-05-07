define [ 'constant', 'jquery', 'MC','i18n!nls/lang.js', 'ebs_service' , '../result_vo' ], ( constant, $, MC, lang, ebsService ) ->

	isSnapshotExist = (callback) ->

		try
			if !callback
				callback = () ->

			# get current stack all snaphost
			snaphostAry = []
			snaphostMap = {}
			_.each MC.canvas_data.component, (compObj) ->
				if compObj.type is constant.RESTYPE.SNAP
					snaphostId = compObj.resource.SnapshotId
					instanceUID = compObj.resource.AttachmentSet.InstanceId
					if snaphostId and instanceUID
						snaphostMap[snaphostId] = instanceUID
				null

			snaphostAry = _.keys(snaphostMap)

			# get ami info from aws
			if snaphostAry.length

				currentRegion = MC.canvas_data.region
				ebsService.DescribeSnapshots {sender: this},
					$.cookie( 'usercode' ),
					$.cookie( 'session_id' ),
					currentRegion, null, null, null, null, (result) ->

						tipInfoAry = []

						if result.is_error and result.aws_error_code is 'InvalidAMIID.NotFound'
							# get current stack all aws ami
							awsAMIIdAryStr = result.error_message
							awsAMIIdAryStr = awsAMIIdAryStr.replace("The image ids '[", "").replace("]' do not exist", "")
							.replace("The image id '[", "").replace("]' does not exist", "")

							awsAMIIdAry = awsAMIIdAryStr.split(',')
							awsAMIIdAry = _.map awsAMIIdAry, (awsAMIId) ->
								return $.trim(awsAMIId)

							if not awsAMIIdAry.length
								callback(null)
								return null

							_.each amiAry, (amiId) ->
								if amiId in awsAMIIdAry
									# not exist in stack
									instanceUIDAry = instanceAMIMap[amiId]
									_.each instanceUIDAry, (instanceUID) ->
										instanceObj = MC.canvas_data.component[instanceUID]
										instanceType = instanceObj.type
										instanceName = instanceObj.name

										infoObjType = 'Instance'
										infoTagType = 'instance'
										if instanceType is constant.RESTYPE.LC
											infoObjType = 'Launch Configuration'
											infoTagType = 'lc'
										tipInfo = sprintf lang.ide.TA_MSG_ERROR_STACK_HAVE_NOT_EXIST_AMI, infoObjType, infoTagType, instanceName, amiId
										tipInfoAry.push({
											level: constant.TA.ERROR,
											info: tipInfo,
											uid: instanceUID
										})
										null
								null

						else if not result.is_error
							descAMIIdAry = []
							descAMIAry = result.resolved_data
							if _.isArray descAMIAry
								_.each descAMIAry, (amiObj) ->
									descAMIIdAry.push(amiObj.imageId)
									null
							_.each amiAry, (amiId) ->
								if amiId not in descAMIIdAry
									# not exist in stack
									instanceUIDAry = instanceAMIMap[amiId]
									_.each instanceUIDAry, (instanceUID) ->
										instanceObj = MC.canvas_data.component[instanceUID]
										instanceType = instanceObj.type
										instanceName = instanceObj.name

										infoObjType = 'Instance'
										infoTagType = 'instance'
										if instanceType is constant.RESTYPE.LC
											infoObjType = 'Launch Configuration'
											infoTagType = 'lc'
										tipInfo = sprintf lang.ide.TA_MSG_ERROR_STACK_HAVE_NOT_AUTHED_AMI, infoObjType, infoTagType, instanceName, amiId
										tipInfoAry.push({
											level: constant.TA.ERROR,
											info: tipInfo,
											uid: instanceUID
										})
										null
								null

						# return error valid result
						if tipInfoAry.length
							callback(tipInfoAry)
							console.log(tipInfoAry)
						else
							callback(null)

				return null

			else
				callback(null)
		catch err
			callback(null)

	isSnapshotExist : isSnapshotExist