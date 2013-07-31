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

		initialize : ->
			null

		_getSGRefNum : (sgUID) ->
			refNum = 0
			sgAry = []
			_.each MC.canvas_data.component, (comp, uid) ->
				compType = comp.type
				if compType is 'AWS.ELB'
					sgAry = sgAry.concat comp.resource.SecurityGroups

				if compType is 'AWS.EC2.Instance'
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

			# get all sg uid
			allSGUIDAry = []
			_.each MC.canvas_data.component, (comp, uid) ->
				if comp.type is 'AWS.EC2.SecurityGroup'
					allSGUIDAry.push comp.uid

			displaySGAry = []

			_.each allSGUIDAry, (uid) ->

				sgComp = MC.canvas_data.component[uid]
				sgCompRes = sgComp.resource

				sgIpPermissionsLength = sgCompRes.IpPermissions.length
				sgIpPermissionsEgressLength = sgCompRes.IpPermissionsEgress.length

				sgChecked = Boolean(uid in parentSGList)

				sgHideCheck = false
				if parent_model.attributes.type is 'stack'
					sgHideCheck = true

				sgIsDefault = false
				if sgIsDefault.name is 'DefaultSG'
					sgComp = true

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

				displaySGAry.push sgDisplayObj

				null

			that.set 'sg_list', displaySGAry
			
			null

		getRuleInfoList : ->
			that = this
			parent_model = that.get 'parent_model'
			if !parent_model or !parent_model.getSGList
				return

			parentSGList = parent_model.getSGList()

			sgRuleAry = []
			_.each parentSGList, (uid) ->

				sgComp = MC.canvas_data.component[uid]
				sgCompRes = sgComp.resource

				sgIpPermissionsAry = sgCompRes.IpPermissions

				_.map sgIpPermissionsAry, (value) ->
					value.Direction = 'inbound'
					return value

				sgIpPermissionsEgressAry = sgCompRes.IpPermissionsEgress

				_.map sgIpPermissionsEgressAry, (value) ->
					value.Direction = 'outbound'
					return value

				sgIpPermissionsAry = sgIpPermissionsAry.concat sgIpPermissionsEgressAry
				sgRuleAry = sgRuleAry.concat sgIpPermissionsAry

				null

			that.set 'sg_rule_list', sgRuleAry

			null

		assignSGToComp : (sgUID, sgChecked) ->

			parent_model = this.get 'parent_model'

			if sgChecked
				parent_model.assignSGToComp sgUID
			else
				parent_model.unAssignSGToComp sgUID

		deleteSGFromComp : (sgUID) ->
			delete MC.canvas_data.component[sgUID]
	}

	model = new SGListModel()

	return model
