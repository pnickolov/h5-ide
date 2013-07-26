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



    }

    return SGRulePopupModel
