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
			if stackType is 'stack'
				stackType = true
			else
				stackType = false
			this.set 'is_stack_sg', stackType

			isELBParent = parent_model.get 'is_elb'

			allElbSGAry = MC.aws.elb.getAllElbSGUID()

			# get all sg uid
			allSGUIDAry = []
			_.each MC.canvas_data.component, (comp, uid) ->
				if comp.type is 'AWS.EC2.SecurityGroup'
					if !(!isELBParent and uid in allElbSGAry)
						allSGUIDAry.push comp.uid

			displaySGAry = []

			sg_full = { full : false }
			enabledSGCount = 0

			appView = false
			if parent_model.get('type') is 'app'
				appView = true

			stackComp = false
			if parent_model.get('is_stack') is true
				stackComp = true

			_.each allSGUIDAry, (uid) ->

				sgComp = MC.canvas_data.component[uid]
				sgCompRes = sgComp.resource

				sgIpPermissionsLength = sgCompRes.IpPermissions.length
				sgIpPermissionsEgressLength = sgCompRes.IpPermissionsEgress.length

				sgChecked = Boolean(uid in parentSGList)
				if sgChecked
					++enabledSGCount

				sgHideCheck = false
				
				if parent_model.get('type') is 'app'
					sgHideCheck = true

				if parent_model.get('is_stack') is true
					sgHideCheck = true

				sgIsDefault = false
				if sgComp.name is 'DefaultSG'
					sgIsDefault = true

				needShow = true
				if !sgChecked and parent_model.get('type') is 'app' and !parent_model.get('is_stack')
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

			isAppView = that.get 'app_view'

			refSGLength = 0
			if stackType and !isAppView
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
			_.each parentSGList, (uid) ->

				sgComp = $.extend true, {}, MC.canvas_data.component[uid]
				sgCompRes = sgComp.resource

				sgIpPermissionsAry = sgCompRes.IpPermissions

				_.map sgIpPermissionsAry, (value) ->
					value.Direction = 'inbound'
					if value.ToPort is value.FromPort
						value.display_port = value.ToPort
					else
						value.display_port = value.FromPort + '-' + value.ToPort

					if value.IpRanges.slice(0,1) is '@'

						value.IpRanges = MC.canvas_data.component[MC.extractID( value.IpRanges )].name

					if value.IpProtocol not in ['tcp', 'udp', 'icmp']

						if value.IpProtocol in [-1, '-1']

							value.IpProtocol = "all"

						else
							value.IpProtocol = "custom(#{value.Protocol})"

					return value

				sgIpPermissionsEgressAry = sgCompRes.IpPermissionsEgress

				_.map sgIpPermissionsEgressAry, (value) ->
					value.Direction = 'outbound'
					if value.ToPort is value.FromPort
						value.display_port = value.ToPort
					else
						value.display_port = value.FromPort + '-' + value.ToPort

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

			that.set 'sg_rule_list', sgRuleAry

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
			MC.aws.sg.updateSGColorLabel parent_model.get 'uid'


		deleteSGFromComp : (sgUID) ->

			MC.aws.sg.deleteRefInAllComp(sgUID)
			delete MC.canvas_data.component[sgUID]
			parent_model = this.get 'parent_model'
			#update sg color label
			MC.aws.sg.updateSGColorLabel parent_model.get 'uid'
	}

	model = new SGListModel()

	return model
