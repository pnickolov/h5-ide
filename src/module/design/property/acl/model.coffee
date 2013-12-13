#############################
#  View Mode for design/property/acl
#############################

define [ '../base/model', "Design", 'constant' ], ( PropertyModel, Design, constant ) ->

    ACLModel = PropertyModel.extend {

        init : (uid) ->

            if @isApp
                @appInit( uid )
                return

            aclObj    = Design.instance().component( uid )
            isDefault = aclObj.get("isDefault")

            assos = _.map aclObj.connections(), ( cn )->
                subnet = cn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )
                {
                    name : subnet.get('name')
                    cidr : subnet.get('cidr')
                }

            rules = aclObj.get("rules").splice(0)

            # Format rules
            _.each rules, ( rule )->
                if not rule.port then rule.port = "All"

                if rule.number is '32767'
                    rule.number   = "*"
                    rule.readOnly = true
                else if rule.number is "100" and isDefault
                    rule.readOnly = true

                switch rule.protocol
                    when "-1" then rule.protocol = "ALL"
                    when "1"  then rule.protocol = "ICMP"
                    when "6"  then rule.protocol = "TCP"
                    when "17" then rule.protocol = "UDP"

            @set {
                uid          : uid
                isDefault    : isDefault
                name         : aclObj.get("name")
                rules        : rules
                associations : _.sortBy assos, name
            }

            @sortRules()
            null

        sortRules : () ->
            key = @get "sortKey"

            if not key or key is "number"
                compare = ( a, b )->
                    a_n = parseInt( a, 10 ) || -1
                    b_n = parseInt( b, 10 ) || -1
                    if a_n > b_n then return 1
                    if a_n = b_n then return 0
                    if a_n < b_n then return -1

            else
                compare = ( a, b )->
                    if a[key] > b[key] then return 1
                    if a[key] = b[key] then return 0
                    if a[key] < b[key] then return -1

            @attributes.rules = @attributes.rules.sort( compare )


        setSortOption : ( key )->
            @set "sortKey", key
            @attributes.rules = _.sortBy @attributes.rules, key
            null

        removeAclRule : ( ruleId ) ->
            Design.instance().component( @get("uid") ).removeRule( ruleId )

        appInit : ( uid ) ->

            component = MC.canvas_data.component[uid]

            aclObj = MC.data.resource_list[MC.canvas_data.region][ component.resource.NetworkAclId ]
            aclObj.name = component.name

            #aclObj.vpc_id = MC.canvas_data.component[aclObj.resource.vpcId.split('.')[0][1...]].resource.VpcId

            aclObj.rule_number = 0
            aclObj.asso_number = 0

            if aclObj.entrySet and aclObj.entrySet.item

                aclObj.rule_number = aclObj.entrySet.item.length

                $.each aclObj.entrySet.item, ( idx, entry ) ->

                    if entry.egress in ['true', true]
                        entry.egress = true
                    else
                        entry.egress = false

                    if entry.protocol == -1 or entry.protocol == '-1'

                        entry.protocolName = 'All'

                    else if entry.protocol == 6 or entry.protocol == '6'

                        entry.protocolName = 'TCP'

                    else if entry.protocol == 17 or entry.protocol == '17'

                        entry.protocolName = 'UDP'

                    else if entry.protocol == 1 or entry.protocol == '1'

                        entry.protocolName = 'ICMP'

                    else

                        entry.protocolName = 'Custom'

                    if entry.protocol is 1 or entry.protocol is '1'
                        entry.partType = '/'
                    else
                        entry.partType = '-'

                    dispPort = '-'
                    # icmp
                    if entry.protocol is '1' or entry.protocol is 1
                        dispPort = entry.icmpTypeCode.type + entry.partType + entry.icmpTypeCode.code
                    else if entry.portRange
                        dispPort = entry.portRange.from + entry.partType + entry.portRange.to
                        if Number(entry.portRange.from) is Number(entry.portRange.to)
                            dispPort = entry.portRange.to
                    entry.dispPort = dispPort

                    null

            if aclObj.associationSet and aclObj.associationSet.item

                aclObj.asso_number = aclObj.associationSet.item.length

                $.each aclObj.associationSet.item, (i, asso) ->

                    $.each MC.canvas_data.component, ( i, comp ) ->

                        if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet and comp.resource.SubnetId == asso.subnetId

                            asso.subnetDisplay = comp.name + '(' + comp.resource.CidrBlock + ')'


                        null

            if aclObj.associationSet and aclObj.associationSet.item

                aclObj.asso_number = aclObj.associationSet.item.length

            else
                aclObj.asso_number = 0

            this.set 'component', aclObj

        addRuleToACL : (ruleObj) ->
            uid = @get 'uid'

            newEntrySet = []

            originEntrySet = MC.canvas_data.component[uid].resource.EntrySet

            currentRuleNumber = ruleObj.rule

            addToACL = true
            _.each originEntrySet, (value, key) ->
                if value.RuleNumber is currentRuleNumber
                    addToACL = false
                null

            if addToACL
                newEntrySet.push {
                    "RuleNumber": ruleObj.rule,
                    "IcmpTypeCode": {
                        "Type": ruleObj.type,
                        "Code": ruleObj.code
                    },
                    "PortRange": {
                        "To": ruleObj.portTo,
                        "From": ruleObj.portFrom
                    },
                    "CidrBlock": ruleObj.source,
                    "Protocol": ruleObj.protocol,
                    "RuleAction": ruleObj.action,
                    "Egress": ruleObj.egress
                }

                newEntrySet = originEntrySet.concat newEntrySet

                MC.canvas_data.component[uid].resource.EntrySet = newEntrySet

                this.trigger 'REFRESH_RULE_LIST', MC.canvas_data.component[uid]

            null

        haveRepeatRuleNumber : (newRuleNumber) ->
            uid = @get 'uid'
            result = false
            entrySet = MC.canvas_data.component[uid].resource.EntrySet
            _.each entrySet, (entryObj) ->
                if entryObj.RuleNumber is newRuleNumber
                    result = true
                null
            return result
    }

    new ACLModel()
