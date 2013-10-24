#############################
#  View Mode for design/property/instance
#############################

define [ 'constant','backbone', 'jquery', 'underscore', 'MC' ], (constant) ->

	SGListModel = Backbone.Model.extend {

		defaults :
			'parent_model' : null
			'show_sg_check' : true
			'sg_list' : null
			'is_stack_sg' : null
			'sg_rule_list' : null
			'app_view' : null
			'only_one_sg' : null

		initialize : ->
			null

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

			that = this
			parent_model = that.get 'parent_model'
			if !parent_model or !parent_model.getSGList
				return

			parentSGList = parent_model.getSGList()

			stackType = parent_model.get 'type'

			if stackType in ['stack', 'app']
				stackType = true
			else
				stackType = false
			this.set 'is_stack_sg', stackType

			currentState = MC.canvas.getState()
			appView = (currentState is 'app')

			stackComp = false
			if parent_model.get('is_stack') is true
				stackComp = true

			isELBParent = parent_model.get 'is_elb'

			allElbSGAry = MC.aws.elb.getAllElbSGUID()

			# get all sg uid
			allSGUIDAry = []
			_.each MC.canvas_data.component, (comp, uid) ->
				if comp.type is 'AWS.EC2.SecurityGroup'
					if !(!isELBParent and !stackComp and uid in allElbSGAry)
						allSGUIDAry.push comp.uid

			displaySGAry = []

			sg_full = { full : false }
			enabledSGCount = 0

			_.each allSGUIDAry, (uid) ->

				sgComp = MC.canvas_data.component[uid]
				sgCompRes = sgComp.resource

				sgIpPermissionsLength = sgCompRes.IpPermissions.length
				sgIpPermissionsEgressLength = if sgCompRes.IpPermissionsEgress then sgCompRes.IpPermissionsEgress.length else 0

				sgChecked = Boolean(uid in parentSGList)
				if sgChecked
					++enabledSGCount

				sgHideCheck = false

				if appView
					sgHideCheck = true

				if parent_model.get('is_stack') is true
					sgHideCheck = true

				sgIsDefault = false
				if sgComp.name is 'DefaultSG'
					sgIsDefault = true

				needShow = true
				if !sgChecked and !stackType and appView
					needShow = false

				# need to display
				sgDisplayObj =
					sgUID : uid
					sgName : sgCompRes.GroupName
					sgDesc : sgCompRes.GroupDescription
					sgRuleNum : sgIpPermissionsLength + sgIpPermissionsEgressLength
					sgMemberNum : that._getSGRefNum uid
					sgChecked : sgChecked
					sgHideCheck : sgHideCheck
					sgIsDefault : sgIsDefault
					sgFull      : sg_full
					sgColor     : MC.aws.sg.getSGColor uid
					isStackSG   : stackType
					needShow    : needShow
					appView     : appView

				displaySGAry.push sgDisplayObj

				null

			#move DefaultSG to the first
			$.each displaySGAry, (key, value) ->
				if value.sgName is "DefaultSG" and key isnt 0

					#move DefaultSG to the first one
					default_sg = displaySGAry.splice(key, 1)
					displaySGAry.unshift default_sg[0]
					false


			if MC.canvas_data.platform != "ec2-classic" && enabledSGCount >= 5
				# In VPC, user can only select 5 SG
				sg_full.full = true

			refSGLength = 0
			if stackType and stackComp and !appView
				refSGLength = displaySGAry.length
			else
				refSGLength = enabledSGCount

			if stackComp and appView
				refSGLength = displaySGAry.length

			if enabledSGCount is 1
				that.set 'only_one_sg', true
			else
				that.set 'only_one_sg', false

			that.set 'sg_list', displaySGAry
			that.set 'sg_length', refSGLength

			null


		getRuleInfoList : ->

			that = this
			parent_model = that.get 'parent_model'
			if !parent_model or !parent_model.getSGList
				return

			parentSGList = parent_model.getSGList()

			sgRuleAry = []

			# get all sg for stack
			if parent_model.get('is_stack') is true
				_.each MC.canvas_data.component, (comp, uid) ->
					if comp.type is 'AWS.EC2.SecurityGroup'
						parentSGList.push comp.uid
					null

			_.each parentSGList, (uid) ->
				if !MC.canvas_data.component[uid] then return
				sgComp = $.extend true, {}, MC.canvas_data.component[uid]
				sgCompRes = sgComp.resource

				sgIpPermissionsAry = sgCompRes.IpPermissions

				_.map sgIpPermissionsAry, (value) ->
					value.Direction = 'inbound'
					if value.ToPort is value.FromPort
						value.display_port = value.ToPort
					else
						partType = '-'
						if value.IpProtocol is 'icmp'
							partType = '/'
						value.display_port = value.FromPort + partType + value.ToPort

					if value.IpRanges.slice(0,1) is '@'

						if MC.canvas_data.component[MC.extractID( value.IpRanges )]
							value.IpRanges = MC.canvas_data.component[MC.extractID( value.IpRanges )].name

					if value.IpProtocol not in ['tcp', 'udp', 'icmp']

						if value.IpProtocol in [-1, '-1']

							value.IpProtocol = "all"

						else
							value.IpProtocol = "custom(#{value.Protocol})"

					return value


				if sgCompRes.IpPermissionsEgress

					sgIpPermissionsEgressAry = sgCompRes.IpPermissionsEgress

					_.map sgIpPermissionsEgressAry, (value) ->
						value.Direction = 'outbound'
						if value.ToPort is value.FromPort
							value.display_port = value.ToPort
						else
							partType = '-'
							if value.IpProtocol is 'icmp'
								partType = '/'
							value.display_port = value.FromPort + partType + value.ToPort

						if value.IpRanges.slice(0,1) is '@'

							value.IpRanges = MC.canvas_data.component[MC.extractID( value.IpRanges )].name

						if value.IpProtocol not in ['tcp', 'udp', 'icmp']

							if value.IpProtocol in [-1, '-1']

								value.IpProtocol = "all"

							else
								value.IpProtocol = "custom(#{value.Protocol})"
						return value

					sgIpPermissionsAry = sgIpPermissionsAry.concat sgIpPermissionsEgressAry


				sgRuleAry = sgRuleAry.concat sgIpPermissionsAry

				null

			unionSGRuleAry = []

			isInAry = (obj, ary) ->
				result = false
				_.each ary, (oriObj) ->
					if _.isEqual(obj, oriObj)
						result = true
					null
				result

			_.each sgRuleAry, (itemObj) ->
				if !isInAry(itemObj, unionSGRuleAry)
					unionSGRuleAry.push(itemObj)
				null

			that.set 'sg_rule_list', unionSGRuleAry

			null

		assignSGToComp : (sgUID, sgChecked) ->

			parent_model = this.get 'parent_model'

			if sgChecked
				if parent_model.assignSGToComp
					parent_model.assignSGToComp sgUID
			else
				if parent_model.unAssignSGToComp
					parent_model.unAssignSGToComp sgUID

			#update sg color label
			MC.aws.sg.updateSGColorLabel parent_model.get('uid')


		deleteSGFromComp : (sgUID) ->

			parent_model = this.get 'parent_model'

			MC.aws.sg.deleteRefInAllComp(sgUID)
			delete MC.canvas_data.component[sgUID]
	}

	model = new SGListModel()

	return model
