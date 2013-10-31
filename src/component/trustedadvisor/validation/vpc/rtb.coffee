define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

    isHasRouteButNoAllowRuleInACL = ( uid ) ->
        components = MC.canvas_data.component
        rt = components[ uid ]
        subnetId = ''
        aclName = ''
        subnetName = ''

        connectSubnet = _.some rt.resource.AssociationSet, ( as ) ->
            if as.SubnetId
                subnetId = as.SubnetId
                realSubnetId = subnetId.split( '.' )[ 0 ].slice( 1 )
                subnetName = components[ realSubnetId ].name
                true

        HasAllowACLRule = () ->
            _.some components, ( component ) ->
                if component.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
                    isSubnetACL = _.some component.resource.AssociationSet, ( as ) ->
                        if as.SubnetId is subnetId
                            return true
                    if isSubnetACL
                        aclName = component.name
                        return _.some component.resource.EntrySet, ( es ) ->
                                    es.RuleAction is 'allow'

        if not connectSubnet or HasAllowACLRule()
            return null

        tipInfo = sprintf lang.ide.TA_MSG_NOTICE_RT_HAS_NO_ALLOW_ACL, aclName, rt.name, subnetName, aclName

        # return
        level   : constant.TA.NOTICE
        info    : tipInfo
        uid     : uid



    # public
    isHasRouteButNoAllowRuleInACL : isHasRouteButNoAllowRuleInACL