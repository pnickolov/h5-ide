define [ 'constant', 'jquery', 'MC','i18n!/nls/lang.js', 'ebs_service' ], ( constant, $, MC, lang, ebsService ) ->

	isSnapshotExist = (callback) ->

		try
			if !callback
				callback = () ->

			# get current stack all snaphost
			snaphostAry = []
			snaphostMap = {}
			_.each MC.canvas_data.component, (compObj) ->

				if compObj.type is constant.RESTYPE.VOL
					snaphostId = compObj.resource.SnapshotId
					instanceUID = compObj.resource.AttachmentSet.InstanceId

					if snaphostId and instanceUID
						if not snaphostMap[snaphostId]
							snaphostMap[snaphostId] = []
						instanceUID = MC.extractID(instanceUID)
						snaphostMap[snaphostId] = _.union(snaphostMap[snaphostId], [instanceUID])

				if compObj.type is constant.RESTYPE.LC

					_.each compObj.resource.BlockDeviceMapping, (blockObj, idx) ->

						if idx > 0

							snaphostId = blockObj.Ebs.SnapshotId
							instanceUID = compObj.uid
							if snaphostId and instanceUID
								if not snaphostMap[snaphostId]
									snaphostMap[snaphostId] = []
								snaphostMap[snaphostId] = _.union(snaphostMap[snaphostId], [instanceUID])

				null

			snaphostAry = _.keys(snaphostMap)

			# get ami info from aws
			if snaphostAry.length

				currentRegion = MC.canvas_data.region
				ebsService.DescribeSnapshots {sender: this},
					$.cookie( 'usercode' ),
					$.cookie( 'session_id' ),
					currentRegion, snaphostAry, null, null, null, (result) ->

						tipInfoAry = []

						if result.is_error and result.aws_error_code is 'InvalidSnapshot.NotFound'

							# get current stack all aws ami
							awsSnapshotIdAryStr = result.error_message
							awsSnapshotIdAryStr = awsSnapshotIdAryStr.replace("The snapshot '", "").replace("' does not exist.", "")

							awsSnapshotIdAry = awsSnapshotIdAryStr.split(',')
							awsSnapshotIdAry = _.map awsSnapshotIdAry, (awsSnapshotId) ->
								return $.trim(awsSnapshotId)

							if not awsSnapshotIdAry.length
								callback(null)
								return null

							_.each snaphostAry, (snapshotId) ->
								if snapshotId in awsSnapshotIdAry
									# not exist in stack
									instanceUIDAry = snaphostMap[snapshotId]
									_.each instanceUIDAry, (instanceUID) ->
										instanceObj = MC.canvas_data.component[instanceUID]
										instanceType = instanceObj.type
										instanceName = instanceObj.name

										infoObjType = 'Instance'
										infoTagType = 'instance'

										instanceId = null

										if instanceType is constant.RESTYPE.LC
											infoObjType = 'Launch Configuration'
											infoTagType = 'lc'
											instanceId = instanceObj.resource.LaunchConfigurationARN
										else
											instanceId = instanceObj.resource.InstanceId

										if not instanceId

											tipInfo = sprintf lang.TA.ERROR_STACK_HAVE_NOT_EXIST_SNAPSHOT, snapshotId, infoObjType, instanceName
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
