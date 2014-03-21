define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

    isAZAlone = () ->

        # check if have Instance/LSG
        instanceCount = _.countBy MC.canvas_data.component, (compObj) ->
            if compObj.type in [constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance, constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration]
                return 'instance'
            else
                return 'others'
        if !instanceCount.instance
            return null

        count = _.countBy MC.canvas_data.component, ( component ) ->
            if component.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone then 'az' else 'others'

        if count.az > 1
            return null

        tipInfo = lang.ide.TA_MSG_WARNING_SINGLE_AZ

        # return
        level   : constant.TA.WARNING
        info    : tipInfo

    # public
    isAZAlone : isAZAlone