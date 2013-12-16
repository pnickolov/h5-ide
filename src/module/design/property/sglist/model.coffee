#############################
#  View Mode for design/property/instance
#############################

define [ "Design", "constant", 'lib/forge/app' ], ( Design, constant, forge_app ) ->

	SGListModel = Backbone.Model.extend {

		defaults :
			'show_sg_check' : true

		_getSGRefNum : (sgUID) ->
			refNum = 0
			sgAry = []
			_.each MC.canvas_data.component, (comp, uid) ->
				compType = comp.type
				if compType is 'AWS.ELB' or compType is 'AWS.AutoScaling.LaunchConfiguration'
					sgAry = sgAry.concat comp.resource.SecurityGroups

				if compType is 'AWS.EC2.Instance' and MC.canvas_data.platform is MC.canvas.PLATFORM_TYPE.EC2_CLASSIC
					sgAry = sgAry.concat comp.resource.SecurityGroupId

				if compType is 'AWS.VPC.NetworkInterface'
					_sgAry = []
					_.each comp.resource.GroupSet, (sgObj) ->
						_sgAry.push sgObj.GroupId
						null
					sgAry = sgAry.concat _sgAry
				null

			_.each sgAry, (value) ->
				refSGUID = value.slice(1).split('.')[0]
				if refSGUID is sgUID
					refNum++
				null

			return refNum

		getSGInfoList : ->

			design       = Design.instance()
			parent_model = @parent_model

			readonly = false
			if design.modeIsApp()
				readonly = true
			else if design.modeIsAppEdit()
				if parent_model.isSGListReadOnly
					readonly = parent_model.isSGListReadOnly()


			isELBParent   = parent_model.get 'is_elb'
			isStackParent = parent_model.get 'is_stack'
			resource      = design.component( parent_model.get("uid") )

			sg_list = []
			enabledSGCount = 0

			for sg in Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup ).allObjects()
				# Ignore ElbSG if the property panel is not stack/elb
				if sg.isElbSg() and not ( isELBParent or isStackParent )
					continue

				needShow = isStackParent or ( not readonly ) or sgChecked
				if not needShow
					continue

				if sg.isElbSg() or sg.get("isDefault") or readonly or isStackParent or resource.get("appId")
					deletable = false
				else
					deletable = true

				assos = sg.connections( "SgAsso" )
				used  = false
				if resource
					for asso in assos
						if asso.connectsTo( resource.id )
							used = true
							++enabledSGCount
							break

				sg_list.push {
					uid         : sg.id
					color       : sg.color
					name        : sg.get("name")
					desc        : sg.get("description")
					ruleCount   : sg.connections( "SgRule" ).length
					memberCount : assos.length
					hideCheck   : readonly or isStackParent
					deletable   : deletable
					used        : used
				}

			sg_list = sg_list.sort ( a_sg, b_sg )->
				if a_sg.name is "DefaultSG" then return -1
				if b_sg.name is "DefaultSG" then return 1
				if a_sg.name <  b_sg.name   then return -1
				if a_sg.name == b_sg.name   then return 0
				if a_sg.name >  b_sg.name   then return 1


			@set {
				is_stack_sg : isStackParent
				only_one_sg : enabledSGCount is 1
				sg_list     : sg_list
				sg_length   : if isStackParent then sg_list.length else enabledSGCount
				readonly    : readonly
			}
			null


		getRuleInfoList : ->

			parent_model = @parent_model
			if (not parent_model) or (not parent_model.getSGList)
				return

			parentSGList = parent_model.getSGList()
			components   = MC.canvas_data.component

			sgRuleAry = []

			for uid in parentSGList
				if not components[uid]
					continue

				sgComp             = $.extend true, {}, components[uid]
				sgCompRes          = sgComp.resource
				sgIpPermissionsAry = sgCompRes.IpPermissions

				for value in sgIpPermissionsAry
					value.Direction = 'inbound'
					if value.ToPort is value.FromPort
						value.display_port = value.ToPort
					else
						partType = if value.IpProtocol is 'icmp' then '/' else '-'
						value.display_port = value.FromPort + partType + value.ToPort

					if value.IpRanges[0] is '@'
						ipRangeUid = MC.extractID( value.IpRanges )
						if components[ ipRangeUid ]
							value.IpRanges = components[ ipRangeUid ].name
							value.sgColor = MC.aws.sg.getSGColor(ipRangeUid)

					if value.IpProtocol not in ['tcp', 'udp', 'icmp']

						if value.IpProtocol in [-1, '-1']

							value.IpProtocol = "all"
							value.FromPort = 0
							value.ToPort = 65535
							value.display_port = '0-65535'

						else
							value.IpProtocol = "custom(#{value.IpProtocol})"


				if sgCompRes.IpPermissionsEgress

					sgIpPermissionsEgressAry = sgCompRes.IpPermissionsEgress

					for value in sgIpPermissionsEgressAry
						value.Direction = 'outbound'
						if value.ToPort is value.FromPort
							value.display_port = value.ToPort
						else
							partType = if value.IpProtocol is 'icmp' then '/' else '-'
							value.display_port = value.FromPort + partType + value.ToPort

						if value.IpRanges.slice(0,1) is '@'

							sgUID = MC.extractID(value.IpRanges)
							value.sgColor = MC.aws.sg.getSGColor(sgUID)
							value.IpRanges = components[sgUID].name

						if value.IpProtocol not in ['tcp', 'udp', 'icmp']

							if value.IpProtocol in [-1, '-1']

								value.IpProtocol = "all"
								value.FromPort = 0
								value.ToPort = 65535
								value.display_port = '0-65535'

							else
								value.IpProtocol = "custom(#{value.IpProtocol})"

					sgIpPermissionsAry = sgIpPermissionsAry.concat sgIpPermissionsEgressAry

				sgRuleAry = sgRuleAry.concat sgIpPermissionsAry

			# reduce repeat
			ruleExistMap = {}
			newSGRuleAry = _.filter sgRuleAry, (sgRuleObj) ->
				key = sgRuleObj.Direction + sgRuleObj.FromPort + sgRuleObj.ToPort + sgRuleObj.IpProtocol + sgRuleObj.IpRanges + sgRuleObj.Groups
				if ruleExistMap[key]
					return false
				else
					ruleExistMap[key] = true
					return true

			@set 'sg_rule_list', newSGRuleAry

			null

		assignSGToComp : (sgUID, sgChecked) ->

			parent_model = @parent_model

			if sgChecked
				if parent_model.assignSGToComp
					parent_model.assignSGToComp sgUID
			else
				if parent_model.unAssignSGToComp
					parent_model.unAssignSGToComp sgUID

			#update sg color label
			MC.aws.sg.updateSGColorLabel parent_model.get('uid')


		deleteSGFromComp : (sgUID) ->
			MC.aws.sg.deleteRefInAllComp(sgUID)
			delete MC.canvas_data.component[sgUID]
			null
	}

	new SGListModel()
