#############################
#  View Mode for design/property/sgrule
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC', 'constant' ], ( constant ) ->

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

            target = MC.canvas_data.layout.connection[line_uid].target

            portMap = {}

            for k,v of target
                portMap[v] = k

            for k,v of target

                if v is 'launchconfig-sg' and not MC.canvas_data.component[k]

                    original_group_uid = MC.canvas_data.layout.component.group[k].originalId

                    for comp_uid, comp of MC.canvas_data.layout.component.node

                        if comp.type is 'AWS.AutoScaling.LaunchConfiguration' and comp.groupUId is original_group_uid

                            for l_id, line_comp of MC.canvas_data.layout.connection

                                tmp_portMap = {}

                                for key,val of line_comp.target
                                    tmp_portMap[val] = key

                                if tmp_portMap['launchconfig-sg'] is comp_uid and line_comp.type is 'elb-sg'

                                    if tmp_portMap['elb-sg-out'] and portMap['elb-sg-out'] and tmp_portMap['elb-sg-out'] is portMap['elb-sg-out']

                                        target = MC.canvas_data.layout.connection[l_id].target

                                        line_uid = l_id

                                        that.set 'line_id', line_uid

                                else

                                    line_uid = MC.aws.lc.getLCLine line_uid

                                    that.set 'line_id', line_uid

            bothSGAry = MC.aws.sg.getSgRuleDetail line_uid

            from_sg_ids = []
            to_sg_ids = []

            $.each bothSGAry, (i, sg_ary) ->

                $.each sg_ary.sg, (j, sg ) ->
                    if i is 0
                        from_sg_ids.push sg.uid
                    else
                        to_sg_ids.push sg.uid

            sg_app_ary = []

            $.each from_sg_ids, (i, sg_uid) ->

                sg_info = that._getSGInfo sg_uid, to_sg_ids

                if sg_info.rules.length > 0

                    sg_app_ary.push sg_info

            $.each to_sg_ids, (i, sg_uid) ->

                sg_info = that._getSGInfo sg_uid, from_sg_ids

                if sg_info.rules.length > 0

                    sg_existing = false

                    for sg in sg_app_ary

                        if sg.name is sg_info.name

                            sg_existing = true

                            for rule_to_sg in sg_info.rules

                                rule_existing = false

                                for rule_from_sg in sg.rules

                                    if rule_from_sg.uid is rule_to_sg.uid

                                        rule_existing = true

                                if not rule_existing

                                    sg.rules.push rule_to_sg

                    if not sg_existing
                        sg_app_ary.push sg_info

            that.set 'sg_group', sg_app_ary

        _getSGInfo : (sgUID, ref_sg_ids) ->

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

                    if rule.IpProtocol isnt 'tcp' and rule.IpProtocol isnt 'udp' and rule.IpProtocol isnt 'icmp'

                        if rule.IpProtocol is '-1' or rule.IpProtocol is -1

                            tmp_rule.protocol = 'all'

                        else
                            tmp_rule.protocol = "Custom(#{rule.IpProtocol})"
                    else
                        tmp_rule.protocol = rule.IpProtocol

                    if rule.FromPort is rule.ToPort then tmp_rule.port = rule.FromPort else tmp_rule.port = rule.FromPort + '-' + rule.ToPort

                    if rule.IpRanges.slice(0,1) is '@' and rule.IpRanges.split('.')[0].slice(1) in ref_sg_ids

                        tmp_rule.connection = MC.canvas_data.component[rule.IpRanges.split('.')[0][1...]].name

                        rules.push tmp_rule

                    if rule.IpRanges is 'amazon-elb/amazon-elb-sg'

                        tmp_rule.connection = rule.IpRanges

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
