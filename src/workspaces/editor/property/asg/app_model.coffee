#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/model', 'constant', 'Design', "CloudResources" ], ( PropertyModel, constant, Design, CloudResources ) ->

  ASGModel = PropertyModel.extend {

    init : ( uid ) ->

        asg_comp = component = Design.instance().component( uid )

        data =
          uid        : uid
          name       : asg_comp.get 'name'
          minSize    : asg_comp.get 'minSize'
          maxSize    : asg_comp.get 'maxSize'
          capacity   : asg_comp.get 'capacity'
          isEditable : @isAppEdit

        @set data

        resource_list = CloudResources(constant.RESTYPE.ASG, Design.instance().region())
        asg_data = resource_list.get(asg_comp.get('appId'))?.toJSON()

        if asg_data
            @set 'hasData', true
            @set 'awsResName', asg_data.AutoScalingGroupName
            @set 'arn', asg_data.id
            @set 'createTime', asg_data.CreatedTime

            if asg_data.TerminationPolicies and asg_data.TerminationPolicies.member
                @set 'term_policy_brief', asg_data.TerminationPolicies.member.join(" > ")

            @handleInstance asg_comp, CloudResources(constant.RESTYPE.INSTANCE, Design.instance().region())?.toJSON(), asg_data

        if not @isAppEdit
            if not asg_data
                return false
            @set 'lcName',   asg_data.LaunchConfigurationName
            @set 'cooldown', asg_data.DefaultCooldown
            @set 'healCheckType', asg_data.HealthCheckType
            @set 'healthCheckGracePeriod', asg_data.HealthCheckGracePeriod

            @handlePolicy asg_comp, CloudResources(constant.RESTYPE.SP , Design.instance().region())?.toJSON(), asg_data
            @handleNotify asg_comp, CloudResources(constant.RESTYPE.NC, Design.instance().region())?.toJSON(), asg_data


        else
            data = component?.toJSON()
            data.uid = uid
            @set data
            lc = asg_comp.get 'lc'

            if not lc
                @set "emptyAsg", true
                return

            @set "has_elb", !!component.get("lc").connections("ElbAmiAsso").length
            @set "isEC2HealthCheck", component.isEC2HealthCheckType()
            @set 'detail_monitor', !!lc.get( 'monitoring' )

            # Notification
            n = component.getNotification()
            @set "notification", n
            @set "has_notification", n.instanceLaunch or n.instanceLaunchError or n.instanceTerminate or n.instanceTerminateError or n.test

            @notiObject = component.getNotiObject()

            # Policies
            @set "policies", _.map data.policies, ( p )->
                data = $.extend true, {}, p.attributes
                data.cooldown = Math.round( data.cooldown / 60 )
                data.alarmData.period = Math.round( data.alarmData.period / 60 )
                data




        null

    handleInstance: ( asg_comp, resource_list, asg_data ) ->
        # Get generated instances
        instance_count  = 0
        instance_groups = []
        instances_map   = {}

        console.debug asg_comp, resource_list, asg_data
        if asg_data.Instances and asg_data.Instances.member
            instance_count = asg_data.Instances.member.length

            for instance, idx in asg_data.Instances.member
                ami =
                    status : if instance.HealthStatus is 'Healthy' then 'green' else 'red'
                    healthy: instance.HealthStatus
                    name   : instance.InstanceId

                az = instance.AvailabilityZone
                if instances_map[ az ]
                    instances_map[ az ].push ami
                else
                    instances_map[ az ] = [ ami ]

            for az, instances of instances_map
                instance_groups.push {
                    name : az
                    instances : instances
                }

        else
            instance_count = 0

        @set 'instance_groups', instance_groups
        @set 'instance_count',  instance_count

    handleNotify: ( asg_comp, resource_list, asg_data ) ->
        # Get notifications
        notifications = resource_list.NotificationConfigurations

        sendNotify = false
        nc_array = [false, false, false, false, false]
        nc_map   =
            "autoscaling:EC2_INSTANCE_LAUNCH" : 0
            "autoscaling:EC2_INSTANCE_LAUNCH_ERROR" : 1
            "autoscaling:EC2_INSTANCE_TERMINATE" : 2
            "autoscaling:EC2_INSTANCE_TERMINATE_ERROR" : 3
            "autoscaling:TEST_NOTIFICATION" : 4

        if notifications
            for notification in notifications
                if notification.AutoScalingGroupName is asg_data.AutoScalingGroupName
                    nc_array[ nc_map[ notification.NotificationType ] ] = true
                    sendNotify = true

        @set 'notifies',   nc_array
        @set 'sendNotify', sendNotify

    handlePolicy: ( asg_comp, resource_list, asg_data ) ->
        # Get policy
        policies = []
        cloudWatchPolicyMap = {}

        for sp in asg_comp.get("policies")
            comp_uid = sp.id
            policy_data = resource_list[ sp.get 'appId' ]
            if not policy_data
                continue

            policy =
                adjusttype : policy_data.AdjustmentType
                adjustment : policy_data.ScalingAdjustment
                step       : policy_data.MinAdjustmentStep
                cooldown   : policy_data.Cooldown
                name       : policy_data.PolicyName
                arn        : sp.get 'appId'

            #cloudWatchPolicyMap[ "#{comp.get 'name'}-alarm" ] = policy

            alarm_data  = resource_list[ sp.get("alarmData").appId ]
            if alarm_data
                actions_arr = [ alarm_data.InsufficientDataActions, alarm_data.OKActions, alarm_data.AlarmActions ]
                trigger_arr = [ 'INSUFFICIANT_DATA', 'OK', 'ALARM' ]

                for actions, idx in actions_arr
                    if not actions
                        continue
                    for action in actions.member
                        if action isnt policy.arn
                            continue

                        # Set arn to empty if we have cloudwatch.
                        # So that view can show cloudwatch info.
                        policy.arn = ""

                        policy.evaluation = sp.get("alarmData").comparisonOperator
                        policy.metric     = alarm_data.MetricName
                        policy.notify     = actions.length is 2
                        policy.periods    = alarm_data.EvaluationPeriods
                        policy.minute     = Math.round( alarm_data.Period / 60 )
                        policy.statistics = alarm_data.Statistic
                        policy.threshold  = alarm_data.Threshold
                        policy.trigger    = trigger_arr[ idx ]
            else
                console.warn "handlePolicy():can not find CloudWatch info of ScalingPolicy"

            policies.push policy

            @set 'policies', _.sortBy(policies, "name")


    setHealthCheckType : ( type ) ->
      Design.instance().component( @get("uid") ).set( "healthCheckType", type )

    setASGMin : ( value ) ->

        uid = @get 'uid'

        Design.instance().component( uid ).set( "minSize", value )

        null

    setASGMax : ( value ) ->

        uid = @get 'uid'

        Design.instance().component( uid ).set( "maxSize", value )

        null

    setASGDesireCapacity : ( value ) ->

        uid = @get 'uid'

        Design.instance().component( uid ).set( "capacity", value )

        null

    setASGCoolDown : ( value ) ->
      Design.instance().component( @get("uid") ).set( "cooldown", value )

    setHealthCheckGrace : ( value ) ->
      Design.instance().component( @get("uid") ).set( "healthCheckGracePeriod", value )

    setNotification : ( notification )->
      n = Design.instance().component( @get("uid") ).setNotification( notification )
      @notiObject = n
      null

    removeTopic: ->
      n = Design.instance().component( @get("uid") ).setNotification( notification )
      n?.removeTopic()


    getNotificationTopicName: () ->
      Design.instance().component( @get("uid") ).getNotificationTopicName()

    setNotificationTopic: ( appId, name ) ->
      Design.instance().component( @get("uid") ).setNotificationTopic( appId, name )

    setTerminatePolicy : ( policies ) ->
      Design.instance().component( @get("uid") ).set("terminationPolicies", policies)
      @set "terminationPolicies", policies
      null

    delPolicy : ( uid ) ->
      Design.instance().component( uid ).remove()
      null

    isDupPolicyName : ( policy_uid, name ) ->
      _.some Design.instance().component( @get("uid") ).get("policies"), ( p ) ->
        if p.id isnt policy_uid and p.get( 'name' ) is name
          return true

    defaultScalingPolicyName : () ->
      component = Design.instance().component( @get("uid") )
      if component.type is "ExpandedAsg"
        component = component.get("originalAsg")
      policies = component.get("policies")
      count = policies.length
      name = "#{@attributes.name}-policy-#{count}"
      currentNames = _.map policies, ( policy ) ->
        policy.get 'name'

      while name in currentNames
        name = "#{@attributes.name}-policy-#{++count}"
      name

    getPolicy : ( uid )->
      data = $.extend true, {}, Design.instance().component( uid ).attributes
      data.cooldown = Math.round( data.cooldown / 60 )
      data.alarmData.period = Math.round( data.alarmData.period / 60 )
      data

    setPolicy : ( policy_detail ) ->
      asg = Design.instance().component( @get("uid") )
      if asg.type is "ExpandedAsg"
        asg = asg.get('originalAsg')

      if policy_detail.sendNotification
        Design.modelClassForType( constant.RESTYPE.TOPIC ).ensureExistence()

      if not policy_detail.uid
        PolicyModel = Design.modelClassForType( constant.RESTYPE.SP )
        policy = new PolicyModel( policy_detail )
        asg.addScalingPolicy( policy )

        policy_detail.uid = policy.id
        @get("policies").push( policy?.toJSON() )

      else
        policy = Design.instance().component( policy_detail.uid )
        alarmData = policy_detail.alarmData
        policy.setAlarm( alarmData )
        delete policy_detail.alarmData
        policy.set policy_detail
        policy_detail.alarmData = alarmData

      if policy_detail.sendNotification and policy_detail.topic
        policy.setTopic policy_detail.topic.appId, policy_detail.topic.name

      null

  }

  new ASGModel()
