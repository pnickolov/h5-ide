#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant', 'event', 'lib/forge/app' ], ( PropertyModel, constant, ide_event, forge_app ) ->

    SgModel = PropertyModel.extend {

        init : ( uid ) ->

            if @isReadOnly
                @appInit uid
                return

            component = MC.canvas_data.component[ uid ]
            comp_res  = component.resource

            # Get Basic Info
            @set 'name', component.name
            @set 'description', comp_res.GroupDescription

            # Get Members
            members = MC.aws.sg.getAllRefComp(uid)
            members = MC.aws.sg.convertMemberNameToReal(members)
            @set 'members', members

            # Get Rule Count
            ruleCount = comp_res.IpPermissions.length
            if comp_res.IpPermissionsEgress
                ruleCount += comp_res.IpPermissionsEgress.length
            @set 'ruleCount', ruleCount

            # Get Rules
            extendCompRes = $.extend(true, {}, comp_res)
            ipPermissions       = extendCompRes.IpPermissions
            ipPermissionsEgress = extendCompRes.IpPermissionsEgress

            @formatRule ipPermissions
            @formatRule ipPermissionsEgress

            @set 'ipPermissions', ipPermissions
            @set 'ipPermissionsEgress', ipPermissionsEgress

            # Set Editable
            isElbSG = MC.aws.elb.isELBDefaultSG(uid)

            if isElbSG
                inputReadOnly = true
            else if @isAppEdit
                # In AppEdit mode, if the SG has no aws resource associated :
                # Meaning it is a newly created SG. So the input should be editable
                inputReadOnly = forge_app.existing_app_resource( uid )

            if inputReadOnly or component.name is 'DefaultSG'
                @set 'nameReadOnly', true
            if inputReadOnly
                @set 'descReadOnly', true

            # If the SG is Elb SG, its rule is not editable
            @set 'ruleEditable', not isElbSG

            @set 'uid', uid
            null

        formatRule : ( rules ) ->

            components = MC.canvas_data.component

            for rule, idx in rules

                rule.ip_display = rule.IpRanges
                if rule.IpRanges.indexOf('@') >= 0
                    sgUID = MC.extractID( rule.IpRanges)
                    rule.ip_display = components[ sgUID ].name
                    rule.sg_color = MC.aws.sg.getSGColor(sgUID)

                # Protocol
                protocol = "" + rule.IpProtocol
                if protocol is "-1"
                    rule.protocol_display = 'all'
                    rule.FromPort   = 0
                    rule.ToPort     = 65535
                else if protocol isnt 'tcp' and protocol isnt 'udp' and protocol isnt 'icmp'
                    rule.protocol_display = "custom(#{rule.IpProtocol})"
                else
                    rule.protocol_display = protocol

                # Port
                if rule.FromPort is rule.ToPort and rule.IpProtocol isnt 'icmp'
                    rule.DispPort = rule.ToPort
                else
                    partType = if rule.IpProtocol is 'icmp' then '/' else '-'
                    rule.DispPort = rule.FromPort + partType + rule.ToPort
            null


        appInit : ( sg_uid ) ->

            # get sg obj
            currentRegion = MC.canvas_data.region
            currentSGComp = MC.canvas_data.component[sg_uid]
            currentSGID = currentSGComp.resource.GroupId
            currentAppSG = MC.data.resource_list[currentRegion][currentSGID]

            members = MC.aws.sg.getAllRefComp sg_uid

            rules = MC.aws.sg.getAllRule currentAppSG, true

            #get sg name
            sg_app_detail =
                uid         : sg_uid
                name        : currentSGComp.name
                groupName   : currentAppSG.groupName
                description : currentAppSG.groupDescription
                groupId     : currentAppSG.groupId
                ownerId     : currentAppSG.ownerId
                vpcId       : currentAppSG.vpcId
                members     : members
                rules       : rules

            @set sg_app_detail
            null

        setSGName : ( value ) ->

            component = MC.canvas_data.component[ @get 'uid' ]
            comp_res  = component.resource

            for sg in MC.canvas_property.sg_list
                if sg.name is comp_res.GroupName
                    sg.name = value

            component.name = comp_res.GroupName = value
            null

        setSGDescription : ( value ) ->
            MC.canvas_data.component[@get 'uid'].resource.GroupDescription = value
            null


        addSGRule : ( rule ) ->

            uid = @get 'uid'

            comp_res = MC.canvas_data.component[uid].resource

            if !rule.direction
                rule.direction = 'inbound'

            if rule.direction == 'inbound'
                rules = comp_res.IpPermissions
            else
                rules = comp_res.IpPermissionsEgress

            existing = _.some rules, ( existing_rule )->
                existing_rule.ToPort is rule.toport and existing_rule.FromPort is rule.fromport and existing_rule.IpRanges is rule.ipranges and existing_rule.IpProtocol is rule.protocol

            if not existing
                tmp =
                    ToPort     : rule.toport
                    FromPort   : rule.fromport
                    IpRanges   : rule.ipranges
                    IpProtocol : rule.protocol
                    inbound    : rule.direction is 'inbound'

                if tmp.inbound
                    comp_res.IpPermissions.push tmp
                else
                    if not comp_res.IpPermissionsEgress
                        comp_res.IpPermissionsEgress = []

                    comp_res.IpPermissionsEgress.push tmp

                # If not existing, return new data to let view to render
                tmpArr = [ tmp ]
                @formatRule tmpArr

                return tmpArr[0]

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
                                return false
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
                                    return false
                            else
                                sg.IpPermissionsEgress.splice idx, 1
                                return false

            ide_event.trigger ide_event.REDRAW_SG_LINE
    }

    new SgModel()
