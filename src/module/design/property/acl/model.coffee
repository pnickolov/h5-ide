#############################
#  View Mode for design/property/acl
#############################

define [ '../base/model', "Design", 'constant', 'i18n!nls/lang.js' ], ( PropertyModel, Design, constant, lang ) ->

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

                if rule.number is '32767'
                    rule.number   = "*"
                    rule.readOnly = true
                else if rule.number is "100" and isDefault
                    rule.readOnly = true
                else if isApp
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

        addAclRule : ( ruleObj ) ->
            Design.instance().component( @get("uid") ).addRule( ruleObj )

            @getRules()
            @sortRules()

            @trigger "REFRESH_RULE_LIST"
            null

        checkRuleNumber : ( rulenumber )->
            rulenumber = Number( rulenumber )
            if not (0 < rulenumber < 32768)
                return lang.ide.PARSLEY_VALID_RULE_NUMBER_1_TO_32767

            if @get("isDefault") and rulenumber is "100"
                return lang.ide.PARSLEY_RULE_NUMBER_100_HAS_EXISTED


            rule = _.find Design.instance().component( @get("uid") ).get("rules"), ( r )->
                r.number is rulenumber

            if rule then return sprintf lang.ide.PARSLEY_RULENUMBER_ALREADY_EXISTS, rulenumber
            return true
    }

    new ACLModel()
