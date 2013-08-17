#############################
#  View Mode for design/property/sgrule
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

	SGRuleModel = Backbone.Model.extend {

		defaults :
			sg_group : [
					{
						name  : "DefaultSG"
						rules : [ {
							egress     : true
							protocol   : "TCP"
							connection : "eni"
							port       : "1234"
						} ]
					}
				]
			sg_app_ary : null
			line_id : null

		initialize : ->
			#listen
			#this.listenTo this, 'change:get_host', this.getHost

		setLineId : ( line_id ) ->

			this.set 'line_id', line_id

		getDispSGList : (line_uid) ->

			that = this

			bothSGAry = MC.aws.sg.getSgRuleDetail line_uid

			sgUIDAry = []
			_.each bothSGAry, (sgObj) ->
				innerSGAry = sgObj.sg
				_.each innerSGAry, (innerSGObj) ->
					sgUID = innerSGObj.uid
					sgUIDAry.push sgUID
					null
				null

			sgUIDAry = _.uniq(sgUIDAry)

			sg_app_ary = []
			_.each sgUIDAry, (sgUID) ->
				sg_app_ary.push that._getSGInfo(sgUID)
				null

			that.set 'sg_group', sg_app_ary

		_getSGInfo : (sgUID) ->

			# get app sg obj
			rules = []

			permissions = [MC.canvas_data.component[sgUID].resource.IpPermissions, MC.canvas_data.component[sgUID].resource.IpPermissionsEgress]

			$.each permissions, (i, permission)->

                $.each permission, ( idx, rule ) ->

                    tmp_rule = {}

                    tmp_rule.uid = sgUID + '_' + i + "_" + idx

                    if i is 0

                    	tmp_rule.egress = false

                    else
                    	tmp_rule.egress = true

                    tmp_rule.protocol = rule.IpProtocol

                    if rule.IpRanges.slice(0,1) is '@'

                        tmp_rule.connection = MC.canvas_data.component[rule.IpRanges.split('.')[0][1...]].name

                    else
                        tmp_rule.connection = rule.IpRanges

                    if rule.FromPort is rule.ToPort then tmp_rule.port = rule.FromPort else tmp_rule.port = rule.FromPort + '-' + rule.ToPort

                    rules.push tmp_rule

			#get sg name
			sg_app_detail =
				name : MC.canvas_data.component[sgUID].resource.GroupName
				rules : rules

			return sg_app_detail

		getAppDispSGList : (line_uid) ->

			that = this

			bothSGAry = MC.aws.sg.getSgRuleDetail line_uid

			sgUIDAry = []
			_.each bothSGAry, (sgObj) ->
				innerSGAry = sgObj.sg
				_.each innerSGAry, (innerSGObj) ->
					sgUID = innerSGObj.uid
					sgUIDAry.push sgUID
					null
				null

			sgUIDAry = _.uniq(sgUIDAry)

			sg_app_ary = []
			_.each sgUIDAry, (sgUID) ->
				sg_app_ary.push that._getAppSGInfo(sgUID)
				null

			that.set 'sg_group', sg_app_ary

		_getAppSGInfo : (sgUID) ->

			# get app sg obj
			currentRegion = MC.canvas_data.region
			currentSGComp = MC.canvas_data.component[sgUID]
			currentSGID = currentSGComp.resource.GroupId
			currentAppSG = MC.data.resource_list[currentRegion][currentSGID]

			members = MC.aws.sg.getAllRefComp sgUID
			rules = MC.aws.sg.getAllRule currentAppSG

			#get sg name
			sg_app_detail =
				groupName : currentAppSG.groupName
				groupDescription : currentAppSG.groupDescription
				groupId : currentAppSG.groupId
				ownerId : currentAppSG.ownerId
				vpcId : currentAppSG.vpcId
				members : members
				rules : rules

			return sg_app_detail

	}

	model = new SGRuleModel()

	return model
