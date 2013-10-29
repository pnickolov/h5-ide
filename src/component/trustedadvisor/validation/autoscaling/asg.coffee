define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

    isHaveLaunchConfiguration = ( uid ) ->
        asg = MC.canvas_data.component[ uid ]
        if asg.resource.LaunchConfigurationName
            return null

        tipInfo = sprintf lang.ide.TA_MSG_ERROR_ASG_HAS_NO_LAUNCH_CONFIG, asg.name

        # return
        level   : constant.TA.ERROR
        info    : tipInfo
        uid     : uid



    # public
    isHaveLaunchConfiguration : isHaveLaunchConfiguration