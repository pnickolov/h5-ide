define [ 'i18n!../../../nls/lang.js', 'MC', 'constant' ], ( lang, MC, constant ) ->

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

						side_sg.sg = ({uid:sg.split('.')[0][1...],name:MC.canvas_data.component[sg.split('.')[0][1...]].name, color:MC.aws.sg.getSGColor(sg.split('.')[0][1...])} for sg in MC.canvas_data.component[connection_obj.uid].resource.SecurityGroupId)

						both_side.push side_sg

					else

						$.each MC.canvas_data.component, ( comp_uid, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (comp.resource.Attachment.InstanceId.split ".")[0][1...] == connection_obj.uid and comp.resource.Attachment.DeviceIndex == '0'

								side_sg = {}

								side_sg.name = MC.canvas_data.component[connection_obj.uid].name

								side_sg.sg = ({name:MC.canvas_data.component[sg.GroupId.split('.')[0][1...]].name, uid:sg.GroupId.split('.')[0][1...], color:MC.aws.sg.getSGColor(sg.GroupId.split('.')[0][1...])} for sg in comp.resource.GroupSet)

								both_side.push side_sg

								return false

				when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

					side_sg = {}

					side_sg.name = MC.canvas_data.component[connection_obj.uid].name

					side_sg.sg = ({uid:sg.GroupId.split('.')[0][1...],name:MC.canvas_data.component[sg.GroupId.split('.')[0][1...]].name, color:MC.aws.sg.getSGColor(sg.GroupId.split('.')[0][1...])} for sg in MC.canvas_data.component[connection_obj.uid].resource.GroupSet)

					both_side.push side_sg

				when constant.AWS_RESOURCE_TYPE.AWS_ELB, constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

					side_sg = {}

					side_sg.name = MC.canvas_data.component[connection_obj.uid].name

					side_sg.sg = ({uid:sg.split('.')[0][1...],name:MC.canvas_data.component[sg.split('.')[0][1...]].name, color:MC.aws.sg.getSGColor(sg.split('.')[0][1...])} for sg in MC.canvas_data.component[connection_obj.uid].resource.SecurityGroups)

					both_side.push side_sg

		return both_side

	createNewSG = () ->

		uid = MC.guid()

		component_data = $.extend(true, {}, MC.canvas.SG_JSON.data)

		component_data.uid = uid

		sg_name = MC.aws.aws.getNewName(constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup)

		component_data.name = sg_name

		component_data.resource.GroupName = sg_name
		vpcUID = MC.aws.vpc.getVPCUID()
		if vpcUID
			component_data.resource.VpcId = '@' + vpcUID + '.resource.VpcId'
		component_data.resource.GroupDescription = lang.ide.PROP_TEXT_CUSTOM_SG_DESC

		component_data.resource.IpPermissions = []

		component_data.resource.IpPermissionsEgress.push {
			"IpProtocol": "-1",
			"IpRanges": "0.0.0.0/0",
			"FromPort": "0",
			"ToPort": "65535",
			"Groups": []
			}

		data = MC.canvas.data.get('component')

		data[uid] = component_data

		MC.canvas.data.set('component', data)

		#add new sg to MC.canvas_property.sg_list
		addSGToProperty component_data

		return uid


	addSGToProperty = (sg) ->
		#add sg to MC.canvas_property.sg_list

		found = false
		prop  = MC.canvas_property

		if !prop

			console.log '[addSGToProperty] no canvas_property found'

		else

			#check exist
			$.each prop.sg_list, (i, item) ->

				if sg.id == item.uid
					found = true
					return false
				null

			if !found

				prop.sg_list.push {
					color  : getNextSGColor()
					member : 0
					name   : sg.name
					uid    : sg.uid
				}


		null


	# initSGColor = () ->
	# #init color property in MC.canvas_property.sg_list

	# 	if MC.canvas_property and MC.canvas_property.sg_list
	# 		$.each MC.canvas_property.sg_list, (key, value) ->

	# 			if key < MC.canvas.SG_COLORS.length
	# 				#use color table
	# 				MC.canvas_property.sg_list[key].color = MC.canvas.SG_COLORS[key]
	# 			else #random color
	# 				rand = Math.floor(Math.random() * 0xFFFFFF).toString(16)
	# 				while rand.length < 6
	# 				  rand = "0" + rand
	# 				MC.canvas_property.sg_list[key].color = rand
	# 	else

	# 		console.error '[initSGColor]Init SG color failed'


	getSGColor = (uid) ->
	#get color from MC.canvas_property.sg_list by sg uid
		color = null

		if MC.canvas_property and MC.canvas_property.sg_list
			#use color table
			$.each MC.canvas_property.sg_list, ( i, value ) ->

				if value.color and value.uid == uid
					color = value.color
					false

		if !color
			#random color
			color = Math.floor(Math.random() * 0xFFFFFF).toString(16)
			while color.length < 6
				color = '0' + color

		'#' + color

	getNextSGColor = () ->
	#for createNewSG()
	#get next availability color from MC.canvas.SG_COLORS
		next_color = null

		if MC.canvas_property and MC.canvas_property.sg_list
			#use color table

			$.each MC.canvas.SG_COLORS, ( i, color ) ->

				found = false

				$.each MC.canvas_property.sg_list, ( j, sg ) ->

					if sg.color == color

						found = true

						false

				if !found

					next_color = color

					false

		if !next_color
			#random next_color
			next_color = Math.floor(Math.random() * 0xFFFFFF).toString(16)
			while next_color.length < 6
				next_color = '0' + next_color

		#no '#'
		next_color


	updateSGColorLabel = ( uid ) ->

		if uid
			MC.canvas.updateSG uid
		else
			# console.error '[updateSGColorLabel] not found uid: ' + uid

		null


	#public
	getAllRefComp      : getAllRefComp
	getAllRule         : getAllRule
	getSgRuleDetail    : getSgRuleDetail
	createNewSG        : createNewSG
	addSGToProperty    : addSGToProperty
	getSGColor         : getSGColor
	updateSGColorLabel : updateSGColorLabel
