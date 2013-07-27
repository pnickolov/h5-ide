#############################
#  View Mode for component/sgrule
#############################

define [ 'constant', 'event', 'backbone', 'jquery', 'underscore', 'MC' ], ( constant, ide_event ) ->

    SGRulePopupModel = Backbone.Model.extend {

        defaults :

            sg_detail : null

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

            if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

                this.set 'isnt_classic', false

            both_side = []

            options = MC.canvas.lineTarget line_id

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

                    when constant.AWS_RESOURCE_TYPE.AWS_ELB

                        side_sg = {}

                        side_sg.name = MC.canvas_data.component[connection_obj.uid].name

                        side_sg.sg = ({uid:sg.split('.')[0][1...],name:MC.canvas_data.component[sg.split('.')[0][1...]].name} for sg in MC.canvas_data.component[connection_obj.uid].resource.SecurityGroups)

                        both_side.push side_sg

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

            if not existing

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


        addSGRule : ( rule_data ) ->

            sg_id = rule_data.sgId

            from_port = ''

            to_port = ''

            if rule_data.protocol == 'icmp'

                from_port = rule_data.protocolValue

                if rule_data.protocolSubValue then to_port = rule_data.protocolSubValue

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

            if rule_data.isInbound then MC.canvas_data.component[sg_id].resource.IpPermissions.push sg_rule else MC.canvas_data.component[sg_id].resource.IpPermissionsEgress.push sg_rule

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
                            
                            $.each MC.canvas_data.component[connection_obj.uid].resource.SecurityGroupId, ( i, sg )->

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

                _.map [ MC.canvas_data.component[from_sg_uid].resource.IpPermissions, MC.canvas_data.component[from_sg_uid].resource.IpPermissions ], ( permissions ) ->

                    $.each permissions, ( idx, from_rule ) ->

                        if from_rule.IpRanges.indexOf('@') >=0 and from_rule.IpRanges.split('.')[0][1...] in to_sg_list

                            existing = false

                            to_rule_name = MC.canvas_data.component[from_rule.IpRanges.split('.')[0][1...]].name

                            $.each me.display_rule, ( k, v ) ->
                            
                                if v.name == MC.canvas_data.component[from_sg_uid].name

                                    existing = true

                                    rule_exist = false

                                    new_rule_string = JSON.stringify [to_rule_name, from_rule.FromPort, from_rule.ToPort, from_rule.IpProtocol, idx]

                                    _.map v.rule, ( rule_json ) ->

                                        if JSON.stringify(rule_json) == new_rule_string

                                            rule_exist = true

                                    if not rule_exist

                                        v.rule.push [to_rule_name, from_rule.FromPort, from_rule.ToPort, from_rule.IpProtocol, idx]


                            if not existing

                                tmp = {}

                                tmp.name = MC.canvas_data.component[from_sg_uid].name

                                tmp.rule = []

                                tmp.rule.push [to_rule_name, from_rule.FromPort, from_rule.ToPort, from_rule.IpProtocol, idx]

                                me.display_rule.push tmp
            
            me.display_rule

        deleteSGLine : () ->

            rule_detail = this.get 'delete_rule_list'



    }

    return SGRulePopupModel
