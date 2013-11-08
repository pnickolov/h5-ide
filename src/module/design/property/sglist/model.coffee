#############################
#  View Mode for design/property/instance
#############################

define [ 'lib/forge/app' ], ( forge_app ) ->

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

			parent_model = @parent_model
			if !parent_model or !parent_model.getSGList
				return


			isELBParent   = parent_model.get 'is_elb'
			isStackParent = parent_model.get 'is_stack'

			current_tab_type = MC.canvas.getState()
			if current_tab_type is 'app'
				readonly = true
			else if current_tab_type is 'appedit'
				if parent_model.isSGListReadOnly
					readonly = parent_model.isSGListReadOnly()
				else
					readonly = false
			else
				readonly = false

			parentSGList  = parent_model.getSGList()
			allElbSGAry   = MC.aws.elb.getAllElbSGUID()
			allSGUIDAry   = []
			displaySGAry  = []
			allElbSGMap   = {}

			for uid in allElbSGAry
				allElbSGMap[ uid ] = true

			for uid, comp of MC.canvas_data.component
				if comp.type isnt 'AWS.EC2.SecurityGroup'
					continue
				if isELBParent or isStackParent or not allElbSGMap.hasOwnProperty( uid )
					allSGUIDAry.push uid

			sg_full        = { full : false }
			enabledSGCount = 0
			defaultSG      = null

			for uid in allSGUIDAry

				sgComp = MC.canvas_data.component[uid]
				sgCompRes = sgComp.resource

				sgIpPermissionsLength = sgCompRes.IpPermissions.length
				sgIpPermissionsEgressLength = if sgCompRes.IpPermissionsEgress then sgCompRes.IpPermissionsEgress.length else 0

				sgChecked = uid in parentSGList
				if sgChecked
					++enabledSGCount

				needShow = isStackParent or ( not readonly ) or sgChecked

				if not needShow
					continue

				isDefault = sgComp.name is 'DefaultSG'
				deletable = not ( readonly or isStackParent or isDefault or forge_app.existing_app_resource( uid ) )

				# need to display
				sgDisplayObj =
					sgUID       : uid
					sgName      : sgComp.name
					sgDesc      : sgCompRes.GroupDescription
					sgRuleNum   : sgIpPermissionsLength + sgIpPermissionsEgressLength
					sgMemberNum : @_getSGRefNum uid
					sgChecked   : sgChecked
					sgHideCheck : readonly or isStackParent
					sgIsDefault : isDefault
					sgFull      : sg_full
					sgColor     : MC.aws.sg.getSGColor uid
					readonly    : readonly
					deletable   : deletable

				if sgDisplayObj.sgIsDefault
					defaultSG = sgDisplayObj
				else
					displaySGAry.push sgDisplayObj

			#move DefaultSG to the first
			if defaultSG
				displaySGAry.unshift defaultSG

			# if MC.canvas_data.platform != "ec2-classic" && enabledSGCount >= 5
				# In VPC, user can only select 5 SG
				# sg_full.full = true

			@set 'is_stack_sg', isStackParent
			@set 'only_one_sg', enabledSGCount is 1
			@set 'sg_list',     displaySGAry
			@set 'sg_length',   if isStackParent then displaySGAry.length else enabledSGCount
			@set 'readonly',    readonly
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
						value.display_port = value.FromPort + '-' + value.ToPort

					if value.IpRanges[0] is '@'
						ipRangeUid = MC.extractID( value.IpRanges )
						if components[ ipRangeUid ]
							value.IpRanges = components[ ipRangeUid ].name

					if value.IpProtocol not in ['tcp', 'udp', 'icmp']

						if value.IpProtocol in [-1, '-1']

							value.IpProtocol = "all"

						else
							value.IpProtocol = "custom(#{value.Protocol})"


				if sgCompRes.IpPermissionsEgress

					sgIpPermissionsEgressAry = sgCompRes.IpPermissionsEgress

					for value in sgIpPermissionsEgressAry
						value.Direction = 'outbound'
						if value.ToPort is value.FromPort
							value.display_port = value.ToPort
						else
							value.display_port = value.FromPort + '-' + value.ToPort

						if value.IpRanges.slice(0,1) is '@'

							value.IpRanges = components[MC.extractID( value.IpRanges )].name

						if value.IpProtocol not in ['tcp', 'udp', 'icmp']

							if value.IpProtocol in [-1, '-1']

								value.IpProtocol = "all"

							else
								value.IpProtocol = "custom(#{value.Protocol})"

					sgIpPermissionsAry = sgIpPermissionsAry.concat sgIpPermissionsEgressAry

				sgRuleAry = sgRuleAry.concat sgIpPermissionsAry

			@set 'sg_rule_list', sgRuleAry

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
