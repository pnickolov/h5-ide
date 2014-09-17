define [ 'constant', 'MC','i18n!/nls/lang.js' ], ( constant, MC, lang ) ->

    isConnectSubnetButNoAllowRule = ( uid ) ->
        components = MC.canvas_data.component
        acl = components[ uid ]

        connectSubnet = _.some acl.resource.AssociationSet, ( as ) ->
            if as.SubnetId
                true

        HasAllowACLRule = _.some acl.resource.EntrySet, ( es ) ->
            es.RuleAction is 'allow'

        if not connectSubnet or HasAllowACLRule
            return null

        tipInfo = sprintf lang.TA.NOTICE_ACL_HAS_NO_ALLOW_RULE, acl.name

        # return
        level   : constant.TA.NOTICE
        info    : tipInfo
        uid     : uid



    # public
    isConnectSubnetButNoAllowRule : isConnectSubnetButNoAllowRule
