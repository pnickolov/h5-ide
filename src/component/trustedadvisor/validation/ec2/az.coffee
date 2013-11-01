define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

    isAZAlone = () ->
        count = _.countBy MC.canvas_data.layout.component.group, ( component ) ->
            if component.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone then 'az' else 'others'

        if count.az > 1
            return null

        tipInfo = lang.ide.TA_MSG_WARNING_SINGLE_AZ

        # return
        level   : constant.TA.WARNING
        info    : tipInfo



    # public
    isAZAlone : isAZAlone