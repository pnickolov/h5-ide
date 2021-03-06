define [ 'constant', 'MC', 'i18n!/nls/lang.js', 'TaHelper', 'CloudResources' ], ( constant, MC, lang, Helper, CloudResources ) ->

    i18n = Helper.i18n.short()

    isHasLaunchConfiguration = ( uid ) ->
        asg = MC.canvas_data.component[ uid ]
        if asg.resource.LaunchConfigurationName
            return null

        tipInfo = sprintf lang.TA.ERROR_ASG_HAS_NO_LAUNCH_CONFIG, asg.name

        # return
        level   : constant.TA.ERROR
        info    : tipInfo
        uid     : uid


    isNotificationNotHasTopic = ( uid ) ->
        asg = Design.instance().component uid
        notification = asg.getNotiObject()
        if not notification or not notification.isEffective()
            return null

        topic = notification.getTopic()
        if topic and topic.get('appId')
            return null

        Helper.message.error uid, i18n.ERROR_ASG_NOTIFICATION_NO_TOPIC, asg.get 'name'

    isPolicyNotHasTopic = ( uid ) ->
        asg = Design.instance().component uid
        policies = asg.get("policies") or []

        result = []
        for p in policies
            if not p.isNotificate() or p.getTopic()
                continue
            result.push Helper.message.error p.id, i18n.ERROR_ASG_POLICY_NO_TOPIC, asg.get('name'), p.get('name')

        result

    isTopicNonexist = ( callback ) ->
        allAsg = Design.modelClassForType( constant.RESTYPE.ASG ).allObjects()

        needTa = []

        for asg in allAsg
            # notification validate
            notification = asg.getNotiObject()
            notiValid = false

            if not notification or not notification.isEffective()
                notiValid = true
            else
                topic = notification.getTopic()

                if not topic
                    notiValid = true

            if not notiValid
                needTa.push [ topic, asg, notification ]

            # policies validate

            policies = asg.get("policies") or []

            for p in policies
                topic = p.getTopic()
                if p.isNotificate() and topic
                    needTa.push [ topic, asg, p ]


        if _.isEmpty needTa
            callback null
            return

        region = Design.instance().region()
        topicCol = CloudResources Design.instance().credentialId(), constant.RESTYPE.TOPIC, region

        result = []
        topicCol.fetchForce().fin ->
            for ta in needTa
                topic = ta[0]
                asg = ta[1]
                obj = ta[2]

                if not topicCol.get topic.get 'appId'

                    if obj.type is constant.RESTYPE.SP
                        result.push Helper.message.error obj.id, i18n.ERROR_ASG_POLICY_TOPIC_NONEXISTENT, asg.get('name'), obj.get('name'), topic.get('name')

                    else if obj.type is constant.RESTYPE.NC
                        result.push Helper.message.error obj.id, i18n.ERROR_ASG_NOTIFICITION_TOPIC_NONEXISTENT, asg.get('name'), topic.get('name')


            callback result









    # public
    isHasLaunchConfiguration    : isHasLaunchConfiguration
    isNotificationNotHasTopic   : isNotificationNotHasTopic
    isPolicyNotHasTopic         : isPolicyNotHasTopic
    isTopicNonexist             : isTopicNonexist
