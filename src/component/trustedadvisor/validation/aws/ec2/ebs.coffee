define [ 'constant', 'jquery', 'MC','i18n!/nls/lang.js', "CloudResources" ], ( constant, $, MC, lang, CloudResources ) ->

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

				cr = CloudResources( constant.RESTYPE.SNAP, Design.instance().region() )
				failure = ()-> callback( null )
				success = ()->

					tipInfoAry = []
					missingIds = []

					for id in snaphostAry
						if not cr.get(id)
							missingIds.push id

					if not missingIds.length
						callback(null)
						return

					for snapshotId in missingIds

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

						# return error valid result
						if tipInfoAry.length
							callback(tipInfoAry)
							console.log(tipInfoAry)
						else
							callback(null)

				cr.fetch().then success, failure
				return null

			else
				callback(null)
		catch err
			callback(null)

	isSnapshotExist : isSnapshotExist
