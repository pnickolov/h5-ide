#############################
#  View Mode for design/property/acl
#############################

define [ '../base/model', "Design", 'constant', 'i18n!nls/lang.js' ], ( PropertyModel, Design, constant, lang ) ->

    icmpTypeMap = {
        "0": "Echo Reply(0)",
        "3": "Destination Unreachable(3)",
        "4": "Source Quench(4)",
        "5": "Redirect Message(5)",
        "6": "Alternate Host Address(6)",
        "8": "Echo Request(8)",
        "9": "Router Advertisement(9)",
        "10": "Router Solicitation(10)",
        "11": "Time Exceeded(11)",
        "12": "Parameter Problem: Bad IP header(12)",
        "13": "Timestamp(13)",
        "14": "Timestamp Reply(14)",
        "15": "Information Request(15)",
        "16": "Information Reply(16)",
        "17": "Address Mask Request(17)",
        "18": "Address Mask Reply(18)",
        "30": "Traceroute(30)",
        "31": "Datagram Conversion Error(31)",
        "32": "Mobile Host Redirect(32)",
        "33": "Where Are You(33)",
        "34": "Here I Am(34)",
        "35": "Mobile Registration Request(35)",
        "36": "Mobile Registration Reply(36)",
        "37": "Domain Name Request(37)",
        "38": "Domain Name Reply(38)",
        "39": "SKIP Algorithm Discovery Protocol(39)",
        "40": "Photuris Security Failures(40)",
        "-1": "All(-1)"
    }

    icmpCodeMap = {
        "3": {
            "-1": "All(-1)",
            "0": "destination network unreachable(0)",
            "1": "destination host unreachable(1)",
            "2": "destination protocol unreachable(2)",
            "3": "destination port unreachable(3)",
            "4": "fragmentation required and DF flag set(4)",
            "5": "source route failed(5)",
            "6": "destination network unknown(6)",
            "7": "destination host unknown(7)",
            "8": "source host isolated(8)",
            "9": "network administratively prohibited(9)",
            "10": "host administratively prohibited(10)",
            "11": "network unreachable for TOS(11)",
            "12": "host unreachable for TOS(12)",
            "13": "communication administratively prohibited(13)"
        },
        "5": {
            "-1": "All(-1)",
            "0": "redirect datagram for the network(0)",
            "1": "redirect datagram for the host(1)",
            "2": "redirect datagram for the TOS & network(2)",
            "3": "redirect datagram for the TOS & host(3)"
        },
        "11": {
            "-1": "All(-1)",
            "0": "TTL expired transit(0)",
            "1": "fragmentation reasembly time exceeded(1)"
        },
        "12": {
            "-1": "All(-1)",
            "0": "pointer indicates the error(0)",
            "1": "missing a required option(1)",
            "2": "bad length(2)"
        }
    }

    ACLModel = PropertyModel.extend {

        init : (uid) ->

            aclObj = Design.instance().component( uid )

            assos = _.map aclObj.connectionTargets( "AclAsso" ), ( subnet )->
                {
                    name : subnet.get('name')
                    cidr : subnet.get('cidr')
                }

            @set {
                uid          : uid
                isDefault    : aclObj.isDefault()
                appId        : aclObj.get("appId")
                name         : aclObj.get("name")
                vpcId        : Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).theVPC().get("appId")
                rules        : null
                isApp        : @isApp
                associations : _.sortBy assos, name
            }

            @getRules()
            @sortRules()
            null

        getRules : ()->
            rules = $.extend true, [], Design.instance().component( @get("uid") ).get("rules")

            isDefault = @get("isDefault")

            isApp = @isApp

            # Format rules
            _.each rules, ( rule )->

                if not rule.port then rule.port = "All"

                if rule.number is 32767
                    rule.number   = "*"
                    rule.readOnly = true
                else if (rule.number is 100 and isDefault) or isApp
                    rule.readOnly = true

                switch rule.protocol
                    when -1 then rule.protocol = "ALL"
                    when 1  then rule.protocol = "ICMP"
                    when 6  then rule.protocol = "TCP"
                    when 17 then rule.protocol = "UDP"

                if rule.protocol is 'ICMP'
                    typeCodeStrAry = rule.port.split('/')

                    typeStr = ''
                    if typeCodeStrAry[0]
                        typeStr = icmpTypeMap[typeCodeStrAry[0]]

                    codeStr = ''
                    if typeCodeStrAry[1]
                        if icmpCodeMap[typeCodeStrAry[0]]
                            codeStr = icmpCodeMap[typeCodeStrAry[0]][typeCodeStrAry[1]]
                        else
                            codeStr = "All(-1)"

                    if typeStr and not codeStr
                        rule.tooltip = 'Type: ' + typeStr
                    else if typeStr and codeStr
                        rule.tooltip = 'Type: ' + typeStr + ', ' + 'Code: ' + codeStr
                else
                    rule.tooltip = 'Port: ' + rule.port

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

        addAclRule : ( ruleObj ) ->
            Design.instance().component( @get("uid") ).addRule( ruleObj )

            @getRules()
            @sortRules()

            @trigger "REFRESH_RULE_LIST"
            null

        checkRuleNumber : ( rulenumber )->
            rulenumber = parseInt rulenumber, 10
            if not (0 < rulenumber < 32768)
                return lang.ide.PARSLEY_VALID_RULE_NUMBER_1_TO_32767

            if @get("isDefault") and rulenumber is 100
                return lang.ide.PARSLEY_RULE_NUMBER_100_HAS_EXISTED


            rule = _.find Design.instance().component( @get("uid") ).get("rules"), ( r )->
                r.number is rulenumber

            if rule then return sprintf lang.ide.PARSLEY_RULENUMBER_ALREADY_EXISTS, rulenumber
            return true
    }

    new ACLModel()
