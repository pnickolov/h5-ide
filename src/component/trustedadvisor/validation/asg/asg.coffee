define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

    isHasLaunchConfiguration = ( uid ) ->
        asg = MC.canvas_data.component[ uid ]
        if asg.resource.LaunchConfigurationName
            return null

        tipInfo = sprintf lang.ide.TA_MSG_ERROR_ASG_HAS_NO_LAUNCH_CONFIG, asg.name

        # return
        level   : constant.TA.ERROR
        info    : tipInfo
        uid     : uid


    isELBHasHealthCheck = ( uid ) ->
        asg =  MC.canvas_data.component[ uid ]

        isConnectELB = MC.canvas_data.component[ uid ].resource.LoadBalancerNames.length > 0
        if not isConnectELB or isConnectELB and asg.resource.HealthCheckType is 'ELB'
            return null

        tipInfo = sprintf lang.ide.TA_MSG_WARNING_ELB_HEALTH_NOT_CHECK, asg.name

        # return
        level   : constant.TA.WARNING
        info    : tipInfo
        uid     : uid

    # public
    isHasLaunchConfiguration    : isHasLaunchConfiguration
    isELBHasHealthCheck         : isELBHasHealthCheck
