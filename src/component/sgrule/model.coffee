#############################
#  View Mode for component/sgrule
#############################

define [ 'constant', 'event', 'backbone', 'jquery', 'underscore', 'MC' ], ( constant, ide_event ) ->

    SGRulePopupModel = Backbone.Model.extend {

        defaults :

            sg_detail : null

            sg_group : []

            preview_rule : null

            line_id : null

            isnt_classic : true

            delete_rule_list : null

        initialize : ->
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.updatePlatform

        updatePlatform : ( type ) ->

            if type is 'OLD_APP' or  type is 'OLD_STACK'

                if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

                    this.set 'isnt_classic', false

                else
                    this.set 'isnt_classic', true

        getSgRuleDetail : ( line_id ) ->

            this.set 'line_id', line_id

            this.set 'target', MC.canvas_data.layout.connection[line_id].target

            if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

                this.set 'isnt_classic', false

            else
                this.set 'isnt_classic', true


            both_side = MC.aws.sg.getSgRuleDetail line_id

            this.set 'sg_detail', both_side

        checkRuleExisting : () ->

            me = this

            sg_detail = this.get 'sg_detail'


            existing = false

            $.each sg_detail[0].sg, ( i, from_sg ) ->

                $.each sg_detail[1].sg, ( j, to_sg ) ->

                    result = me._checkRule from_sg, to_sg

                    if result

                        existing = result

                        return false

                if existing

                    return false

            if not existing and MC.canvas_data.layout.connection[this.get('line_id')]

                this.trigger 'DELETE_LINE', this.get('line_id')


        _checkRule : ( from_sg, to_sg) ->

            existing = false

            $.each MC.canvas_data.component[from_sg.uid].resource.IpPermissions, ( idx, rule ) ->

                if rule.IpRanges.indexOf('@') >= 0 and rule.IpRanges.split('.')[0][1...] == to_sg.uid

                    existing = true

                    return false

            if not existing

                $.each MC.canvas_data.component[from_sg.uid].resource.IpPermissionsEgress, ( idx, rule ) ->

                    if rule.IpRanges.indexOf('@') >= 0 and rule.IpRanges.split('.')[0][1...] == to_sg.uid

                        existing = true

                        return false


            existing

        getDispSGList : (line_uid) ->

            that = this
            bothSGAry = null

            line_uid = this.getCurrentLineId()
            if line_uid

                bothSGAry = MC.aws.sg.getSgRuleDetail line_uid

            else
                target = this.get('target')
                options = []

                $.each target, (k, v) ->

                    options.push {port:v, uid:k}


                bothSGAry = MC.aws.sg.getSgRuleDetail options

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

            $.each permissions, (i, permission) ->

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

        addSGRule : ( rule_data ) ->

            sg_id = rule_data.sgId

            from_port = ''

            to_port = ''

            if rule_data.protocol == 'icmp'

                from_port = rule_data.protocolValue

                if rule_data.protocolSubValue then to_port = rule_data.protocolSubValue

            else if rule_data.protocol == 'all'
                from_port = 0
                to_port = 65535
            else
                if '-' in rule_data.protocolValue

                    from_port = rule_data.protocolValue.split('-')[0]

                    to_port = rule_data.protocolValue.split('-')[1]

                else
                    from_port = to_port = rule_data.protocolValue


            sg_rule = {
                "IpProtocol": rule_data.protocol
                "IpRanges": '@' + rule_data.direction + '.resource.GroupId'
                "FromPort": from_port
                "ToPort": to_port
                "Groups": [{
                    "GroupId": ""
                    "UserId": ""
                    "GroupName": ""
                }]
            }

            if rule_data.isInbound

                index = MC.canvas_data.component[sg_id].resource.IpPermissions.push sg_rule

            else

                index = MC.canvas_data.component[sg_id].resource.IpPermissionsEgress.push sg_rule

            preview_rule = [sg_id, rule_data.isInbound, index-1]

            this.set 'preview_rule', preview_rule

        getDeleteSGList : () ->

            me = this

            line_id = this.get 'line_id'

            options = MC.canvas.lineTarget line_id

            from_sg_list = []

            to_sg_list = []

            $.each options, ( i, connection_obj ) ->

                switch MC.canvas_data.component[connection_obj.uid].type

                    when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

                        if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

                            $.each MC.canvas_data.component[connection_obj.uid].resource.SecurityGroupId, ( idx, sg )->

                                if i == 0

                                    from_sg_list.push sg.split('.')[0][1...]

                                else

                                    to_sg_list.push sg.split('.')[0][1...]

                        else

                            $.each MC.canvas_data.component, ( comp_uid, comp ) ->

                                if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (comp.resource.Attachment.InstanceId.split ".")[0][1...] == connection_obj.uid and comp.resource.Attachment.DeviceIndex == '0'

                                    $.each MC.canvas_data.component[comp.uid].resource.GroupSet, ( idx, sg ) ->

                                        if i == 0

                                            from_sg_list.push sg.GroupId.split('.')[0][1...]

                                        else

                                            to_sg_list.push sg.GroupId.split('.')[0][1...]


                                    return false


                    when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

                        $.each MC.canvas_data.component[connection_obj.uid].resource.GroupSet, ( idx, sg ) ->

                            if i == 0

                                from_sg_list.push sg.GroupId.split('.')[0][1...]

                            else

                                to_sg_list.push sg.GroupId.split('.')[0][1...]

                    when constant.AWS_RESOURCE_TYPE.AWS_ELB

                        $.each MC.canvas_data.component[connection_obj.uid].resource.SecurityGroups, ( idx, sg )->

                            if i == 0

                                from_sg_list.push sg.split('.')[0][1...]

                            else

                                to_sg_list.push sg.split('.')[0][1...]

            this.display_rule = []

            me._getLineRelateRule( from_sg_list, to_sg_list )

            me._getLineRelateRule( to_sg_list, from_sg_list )

            this.set 'delete_rule_list', this.display_rule

        _getLineRelateRule : ( from_sg_list, to_sg_list ) ->

            me = this

            $.each from_sg_list, ( i, from_sg_uid ) ->

                $.each [ MC.canvas_data.component[from_sg_uid].resource.IpPermissions, MC.canvas_data.component[from_sg_uid].resource.IpPermissionsEgress ], ( i, permission ) ->

                    $.each permission, ( idx, from_rule ) ->

                        if from_rule.IpRanges.indexOf('@') >=0 and from_rule.IpRanges.split('.')[0][1...] in to_sg_list

                            existing = false

                            to_rule_name = MC.canvas_data.component[from_rule.IpRanges.split('.')[0][1...]].name

                            $.each me.display_rule, ( k, v ) ->

                                if v.name == MC.canvas_data.component[from_sg_uid].name

                                    existing = true

                                    rule_exist = false

                                    new_rule_string = JSON.stringify [to_rule_name, from_rule.FromPort, from_rule.ToPort, from_rule.IpProtocol, i, from_rule.IpRanges]

                                    _.map v.rule, ( rule_json ) ->

                                        if JSON.stringify(rule_json) == new_rule_string

                                            rule_exist = true

                                    if not rule_exist

                                        v.rule.push [to_rule_name, from_rule.FromPort, from_rule.ToPort, from_rule.IpProtocol, i, from_rule.IpRanges]


                            if not existing

                                tmp = {}

                                tmp.name = MC.canvas_data.component[from_sg_uid].name

                                tmp.rule = []

                                tmp.rule.push [to_rule_name, from_rule.FromPort, from_rule.ToPort, from_rule.IpProtocol, i, from_rule.IpRanges]

                                me.display_rule.push tmp

            me.display_rule

        deleteSGLine : () ->

            rule_detail = this.get 'delete_rule_list'

            $.each rule_detail, ( i , rule ) ->

                $.each MC.canvas_data.component, ( comp_uid, comp ) ->

                    if comp.name == rule.name

                        $.each rule.rule, ( i, delete_rule ) ->

                            permissions = [ comp.resource.IpPermissions, comp.resource.IpPermissionsEgress]

                            $.each permissions, (j, permission) ->

                                delete_idx = []

                                $.each permission, ( idx, inbound_rule ) ->

                                    if inbound_rule and j == delete_rule[4] and inbound_rule.IpRanges == delete_rule[5] and inbound_rule.FromPort == delete_rule[1] and inbound_rule.ToPort == delete_rule[2] and inbound_rule.IpProtocol == delete_rule[3]

                                        delete_idx.push idx

                                $.each delete_idx.sort().reverse(), (delete_index, rule_idx)->

                                    permission.splice rule_idx, 1

        deletePriviewRule : () ->

            preview_rule = this.get 'preview_rule'

            if preview_rule[1]

                MC.canvas_data.component[preview_rule[0]].resource.IpPermissions.splice preview_rule[2], 1

            else

                MC.canvas_data.component[preview_rule[0]].resource.IpPermissionsEgress.splice preview_rule[2], 1

        deleteSGRule : ( rule_id ) ->

            rule_detail = rule_id.split('_')


            if rule_detail[1] is '0'

                MC.canvas_data.component[rule_detail[0]].resource.IpPermissions.splice parseInt(rule_detail[2],10), 1

            else

                MC.canvas_data.component[rule_detail[0]].resource.IpPermissionsEgress.splice parseInt(rule_detail[2],10), 1

        getCurrentLineId : () ->

            me = this

            line_id = ''

            target = this.get 'target'

            target_ids = []

            $.each target, ( k, v ) ->

                    target_ids.push k


            $.each MC.canvas_data.layout.connection, ( l_id, line_data ) ->

                tmp_target = line_data.target

                tmp_target_ids = []

                $.each tmp_target, ( k, v ) ->

                    tmp_target_ids.push k

                if target_ids[0] in tmp_target_ids and target_ids[1] in tmp_target_ids

                    line_id = l_id

                    me.set 'line_id', line_id

                    return false

            line_id


    }

    return SGRulePopupModel
