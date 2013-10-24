#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant' ], ( PropertyModel, constant ) ->

    SgModel = PropertyModel.extend {

        defaults :
            'sg_detail'     : null
            'sg_app_detail' : null
            'is_elb_sg'     : false

        init : ( uid ) ->

            if @isReadOnly
                @appInit uid
                return

            me = this

            sg_detail = {}

            sg_detail.component = $.extend true, {}, MC.canvas_data.component[uid]

            if MC.canvas_data.component[uid].resource.IpPermissionsEgress
                sg_detail.rules = MC.canvas_data.component[uid].resource.IpPermissions.length + MC.canvas_data.component[uid].resource.IpPermissionsEgress.length
            else
                sg_detail.rules = MC.canvas_data.component[uid].resource.IpPermissions.length

            sg_detail.members = MC.aws.sg.getAllRefComp(uid)

            sg_detail.members = MC.aws.sg.convertMemberNameToReal(sg_detail.members)

            if sg_detail.component.resource.IpPermissionsEgress
                permissions = [sg_detail.component.resource.IpPermissions, sg_detail.component.resource.IpPermissionsEgress]
            else
                permissions = [sg_detail.component.resource.IpPermissions]

            $.each permissions, (j, permission)->

                $.each permission, ( i, rule ) ->

                    if rule.IpRanges.indexOf('@') >=0

                        rule.ip_display = MC.canvas_data.component[rule.IpRanges.split('.')[0][1...]].name

                    else

                        rule.ip_display = rule.IpRanges

                    if rule.IpProtocol in [-1, '-1']

                        rule.protocol_display = 'all'

                        rule.FromPort = 0

                        rule.ToPort = 65535

                    else if rule.IpProtocol not in ['tcp', 'udp', 'icmp', -1, '-1']

                        rule.protocol_display = "custom(#{rule.IpProtocol})"

                    else
                        rule.protocol_display = rule.IpProtocol

                    if rule.IpProtocol is 'icmp'
                        rule.PartType = '/'
                    else
                        rule.PartType = '-'

                    dispPort = rule.FromPort + rule.PartType + rule.ToPort
                    if Number(rule.FromPort) is Number(rule.ToPort) and rule.IpProtocol isnt 'icmp'
                        dispPort = rule.ToPort

                    rule.DispPort = dispPort

                    null

            @set( 'sg_detail', sg_detail )

            is_elb_sg = MC.aws.elb.isELBDefaultSG(uid)
            @set( 'is_elb_sg', is_elb_sg )

            inputReadOnly = is_elb_sg or @isAppEdit

            if inputReadOnly or sg_detail.component.name is 'DefaultSG'
                @set( 'nameReadOnly', true )

            if inputReadOnly
                @set( 'descReadOnly', true )

            @set( 'uid', uid )
            null

        appInit : ( sg_uid ) ->

            # get sg obj
            currentRegion = MC.canvas_data.region
            currentSGComp = MC.canvas_data.component[sg_uid]
            currentSGID = currentSGComp.resource.GroupId
            currentAppSG = MC.data.resource_list[currentRegion][currentSGID]

            members = MC.aws.sg.getAllRefComp sg_uid

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

            @set 'sg_app_detail', sg_app_detail
            @set 'uid', sg_uid

        setSGName : ( value ) ->

            uid = @get 'uid'

            old_name = MC.canvas_data.component[uid].resource.GroupName

            MC.canvas_data.component[uid].resource.GroupName = value

            MC.canvas_data.component[uid].name = value

            new_sg_detail = this.get 'sg_detail'

            new_sg_detail.component.name = value

            new_sg_detail.component.resource.GroupName = value

            this.set 'sg_detail', new_sg_detail

            _.map MC.canvas_property.sg_list, ( sg ) ->

                if sg.name == old_name

                    sg.name = value

                null

            null

        setSGDescription : ( value ) ->

            uid = @get 'uid'

            MC.canvas_data.component[uid].resource.GroupDescription = value

            null


        setSGRule : ( rule ) ->

            uid = @get 'uid'

            rules = null
            existing = false

            if !rule.direction then rule.direction = 'inbound'
            if rule.direction == 'inbound'
                rules = MC.canvas_data.component[uid].resource.IpPermissions
            else
                rules = MC.canvas_data.component[uid].resource.IpPermissionsEgress

            _.map rules, ( existing_rule ) ->

                if existing_rule.ToPort == rule.toport and existing_rule.FromPort == rule.fromport and existing_rule.IpRanges == rule.ipranges and existing_rule.IpProtocol == rule.protocol

                    existing = true

                    null

            if not existing

                tmp = {}
                tmp.ToPort = rule.toport
                tmp.FromPort = rule.fromport
                tmp.IpRanges = rule.ipranges
                tmp.IpProtocol = rule.protocol

                if rule.direction is 'inbound'
                    MC.canvas_data.component[uid].resource.IpPermissions.push tmp
                else
                    if MC.canvas_data.component[uid].resource.IpPermissionsEgress
                        MC.canvas_data.component[uid].resource.IpPermissionsEgress.push tmp

            null


        removeSGRule : ( rule ) ->

            uid = @get 'uid'

            sg = MC.canvas_data.component[uid].resource

            if rule.inbound == true

                $.each sg.IpPermissions, ( idx, value ) ->

                    if rule.protocol.toString() == value.IpProtocol.toString() and value.IpRanges == rule.iprange

                        if rule.protocol.toString() isnt '-1'
                            if rule.fromport.toString() == value.FromPort.toString() and rule.toport.toString() == value.ToPort.toString()
                                sg.IpPermissions.splice idx, 1
                        else
                            sg.IpPermissions.splice idx, 1

                        return false

            else

                if sg.IpPermissionsEgress
                    $.each sg.IpPermissionsEgress, ( idx, value ) ->

                        if rule.protocol.toString() == value.IpProtocol.toString() and value.IpRanges == rule.iprange

                            if rule.protocol.toString() isnt '-1'
                                if rule.fromport.toString() == value.FromPort.toString() and rule.toport.toString() == value.ToPort.toString()
                                    sg.IpPermissionsEgress.splice idx, 1
                            else
                                sg.IpPermissionsEgress.splice idx, 1

                            return false


    }

    new SgModel()
