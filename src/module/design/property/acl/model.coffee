#############################
#  View Mode for design/property/acl
#############################

define [ '../base/model', "Design", 'constant' ], ( PropertyModel, Design, constant ) ->

    ACLModel = PropertyModel.extend {

        init : (uid) ->

            if @isApp
                @appInit( uid )
                return

            aclObj = Design.instance().component( uid )

            assos = _.map aclObj.connectionTargets( "AclAsso" ), ( subnet )->
                {
                    name : subnet.get('name')
                    cidr : subnet.get('cidr')
                }

            @set {
                uid          : uid
                isDefault    : aclObj.isDefault()
                name         : aclObj.get("name")
                rules        : null
                associations : _.sortBy assos, name
            }

            @getRules()
            @sortRules()
            null

        getRules : ()->
            rules = $.extend true, [], Design.instance().component( @get("uid") ).get("rules")

            isDefault = @get("isDefault")

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
                null

            @set "rules", rules

        sortRules : () ->
            key = @get( "sortKey" ) || "number"

            if key is "number"
                compare = ( a, b )->
                    a_n = parseInt( a.number, 10 ) || -1
                    b_n = parseInt( b.number, 10 ) || -1
                    if a_n > b_n then return 1
                    if a_n is b_n then return 0
                    if a_n < b_n then return -1

            else
                compare = ( a, b )->
                    if a[key] > b[key] then return 1
                    if a[key] is b[key] then return 0
                    if a[key] < b[key] then return -1

            @attributes.rules = @attributes.rules.sort( compare )
            null


        setSortOption : ( key )->
            @set "sortKey", key
            @sortRules()
            null

        removeAclRule : ( ruleId ) ->
            Design.instance().component( @get("uid") ).removeRule( ruleId )

        appInit : ( uid ) ->

            component = Design.instance().component( uid )

            aclObj = MC.data.resource_list[Design.instance().region()][ component.get 'appId' ]
            if not aclObj then return false

            aclObj.name = component.get 'name'

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

                        entry.protocolName = 'ALL'

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

                allSubnet = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet ).allObjects()

                _.each aclObj.associationSet.item, ( asso ) ->
                    for subnet in allSubnet
                        if subnet.get( 'appId' ) is asso.subnetId
                            asso.subnetDisplay = "#{subnet.get 'name'}(#{subnet.get 'cidr'})"


            if aclObj.associationSet and aclObj.associationSet.item

                aclObj.asso_number = aclObj.associationSet.item.length

            else
                aclObj.asso_number = 0

            this.set 'component', aclObj

        addAclRule : ( ruleObj ) ->
            Design.instance().component( @get("uid") ).addRule( ruleObj )

            @getRules()
            @sortRules()

            @trigger "REFRESH_RULE_LIST"
            null

        checkRuleNumber : ( rulenumber )->
            if Number( rulenumber ) > 32767
                return 'The maximum value is 32767.'

            if @get("isDefault") and rulenumber is "100"
                return "The DefaultACL's Rule Number 100 has existed."


            rule = _.find Design.instance().component( @get("uid") ).get("rules"), ( r )->
                r.number is rulenumber

            if rule then return 'Rule #{rulenumber} already exists.'
            return true
    }

    new ACLModel()
