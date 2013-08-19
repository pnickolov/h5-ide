define [ 'MC', 'constant' ], ( MC, constant ) ->

	#private
	getAllRefComp = (sgUID) ->

		refNum = 0
		sgAry = []
		refCompAry = []
		_.each MC.canvas_data.component, (comp) ->
			compType = comp.type
			if compType is 'AWS.ELB' or compType is 'AWS.AutoScaling.LaunchConfiguration'
				sgAry = comp.resource.SecurityGroups
				sgAry = _.map sgAry, (value) ->
					refSGUID = value.slice(1).split('.')[0]
					return refSGUID
				if sgUID in sgAry
					refCompAry.push comp

			if compType is 'AWS.EC2.Instance'
				sgAry = comp.resource.SecurityGroupId
				sgAry = _.map sgAry, (value) ->
					refSGUID = value.slice(1).split('.')[0]
					return refSGUID
				if sgUID in sgAry
					refCompAry.push comp

			if compType is 'AWS.VPC.NetworkInterface'
				_sgAry = []
				_.each comp.resource.GroupSet, (sgObj) ->
					_sgAry.push sgObj.GroupId
					null

				sgAry = _sgAry
				sgAry = _.map sgAry, (value) ->
					refSGUID = value.slice(1).split('.')[0]
					return refSGUID

				if sgUID in sgAry
					refCompAry.push comp
			null

		return refCompAry

	getAllRule = (sgRes) ->

		inboundRule = []
		if sgRes.ipPermissionsEgress
			inboundRule = sgRes.ipPermissionsEgress.item
		outboundRule = sgRes.ipPermissions.item

		inboundRule = _.map inboundRule, (ruleObj) ->
			ruleObj.direction = 'inbound'
			return ruleObj

		outboundRule = _.map outboundRule, (ruleObj) ->
			ruleObj.direction = 'outbound'
			return ruleObj

		allRuleAry = inboundRule.concat outboundRule

		allDispRuleAry = []

		_.each allRuleAry, (ruleObj) ->

			ipRanges = ''
			if ruleObj.ipRanges
				ipRanges = ruleObj.ipRanges['item'][0]['cidrIp']
			else
				ipRanges = ruleObj.groups.item[0].groupId

			dispSGObj =
				fromPort : ruleObj.fromPort
				toPort : ruleObj.toPort
				ipProtocol : ruleObj.ipProtocol
				ipRanges : ipRanges
				direction : ruleObj.direction

			allDispRuleAry.push dispSGObj

			null

		return allDispRuleAry

	getSgRuleDetail = (line_id_or_target) ->

		both_side = []

		options = null

		if $.type(line_id_or_target) is "string"

			options = MC.canvas.lineTarget line_id_or_target

		else

			options = line_id_or_target

		$.each options, ( i, connection_obj ) ->

			switch MC.canvas_data.component[connection_obj.uid].type

				when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

					if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

						side_sg = {}

						side_sg.name = MC.canvas_data.component[connection_obj.uid].name

						side_sg.sg = ({uid:sg.split('.')[0][1...],name:MC.canvas_data.component[sg.split('.')[0][1...]].name} for sg in MC.canvas_data.component[connection_obj.uid].resource.SecurityGroupId)

						both_side.push side_sg

					else

						$.each MC.canvas_data.component, ( comp_uid, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (comp.resource.Attachment.InstanceId.split ".")[0][1...] == connection_obj.uid and comp.resource.Attachment.DeviceIndex == '0'

								side_sg = {}

								side_sg.name = MC.canvas_data.component[connection_obj.uid].name

								side_sg.sg = ({name:MC.canvas_data.component[sg.GroupId.split('.')[0][1...]].name, uid:sg.GroupId.split('.')[0][1...]} for sg in comp.resource.GroupSet)

								both_side.push side_sg

								return false

				when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

					side_sg = {}

					side_sg.name = MC.canvas_data.component[connection_obj.uid].name

					side_sg.sg = ({uid:sg.GroupId.split('.')[0][1...],name:MC.canvas_data.component[sg.GroupId.split('.')[0][1...]].name} for sg in MC.canvas_data.component[connection_obj.uid].resource.GroupSet)

					both_side.push side_sg

				when constant.AWS_RESOURCE_TYPE.AWS_ELB, constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

					side_sg = {}

					side_sg.name = MC.canvas_data.component[connection_obj.uid].name

					side_sg.sg = ({uid:sg.split('.')[0][1...],name:MC.canvas_data.component[sg.split('.')[0][1...]].name} for sg in MC.canvas_data.component[connection_obj.uid].resource.SecurityGroups)

					both_side.push side_sg

		return both_side

	createNewSG = () ->

		uid = MC.guid()

		component_data = $.extend(true, {}, MC.canvas.SG_JSON.data)

		component_data.uid = uid

		sg_name = MC.aws.aws.getNewName(constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup)

		component_data.name = sg_name

		component_data.resource.GroupName = sg_name

		tmp = {}
		tmp.uid = uid
		tmp.name = sg_name

		MC.canvas_property.sg_list.push tmp

		data = MC.canvas.data.get('component')

		data[uid] = component_data

		MC.canvas.data.set('component', data)

		return uid

	#public
	getAllRefComp : getAllRefComp
	getAllRule : getAllRule
	getSgRuleDetail : getSgRuleDetail
	createNewSG : createNewSG