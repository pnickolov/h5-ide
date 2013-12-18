#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', "Design", 'constant', 'event'  ], ( PropertyModel, Design, constant, ide_event ) ->

    SgModel = PropertyModel.extend {

        init : ( uid ) ->

            if @isReadOnly
                @appInit uid
                return

            component = Design.instance().component( uid )

            rules = []
            for rule in component.connections("SgRuleSet")
                rules = rules.concat( rule.toPlainObjects( uid ) )

            members = _.map component.connections("SgAsso"), ( asso )->
                asso.getOtherTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup ).get("name")

            @set {
                uid          : uid
                name         : component.get("name")
                description  : component.get("description")
                members      : members
                rules        : rules
                color        : component.color
                ruleEditable : true
            }

            @sortSGRule()

            # Set Editable
            if component.isElbSg()
                inputReadOnly = true

                # If the SG is Elb SG, its rule is not editable
                @set "ruleEditable", false
            else if @isAppEdit
                # In AppEdit mode, if the SG has no aws resource associated :
                # Meaning it is a newly created SG. So the input should be editable
                inputReadOnly = component.get("appId")

            if inputReadOnly or component.get("isDefault")
                @set 'nameReadOnly', true
            if inputReadOnly
                @set 'descReadOnly', true


            null

        sortSGRule : ( key )->
            sgRuleList = _.sortBy @attributes.rules, ( key or "direction" )
            @set "rules", sgRuleList
            null

        addRule : ()->
            null

        removeRule : ( rule )->
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

        setDescription : ( value ) ->
            Design.instance().component( @get("uid") ).set( "description", value )
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
                dispTmp = $.extend(true, {}, tmp)
                tmpArr = [ dispTmp ]
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
