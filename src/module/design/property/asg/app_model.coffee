#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/model', 'constant', 'Design' ], ( PropertyModel, constant, Design ) ->

  ASGModel = PropertyModel.extend {

    init : ( uid ) ->

        asg_comp = Design.instance().component( uid )

        data =
          uid        : uid
          name       : asg_comp.get 'name'
          minSize    : asg_comp.get 'minSize'
          maxSize    : asg_comp.get 'maxSize'
          capacity   : asg_comp.get 'capacity'
          isEditable : @isAppEdit

        @set data

        resource_list = MC.data.resource_list[Design.instance().region()]

        asg_data = resource_list[ asg_comp.get( 'appId' ) ]

        if not asg_data
            return false

        @set 'hasData', true
        @set 'awsResName', asg_data.AutoScalingGroupName
        @set 'arn', asg_data.AutoScalingGroupARN
        @set 'createTime', asg_data.CreatedTime

        if asg_data.TerminationPolicies and asg_data.TerminationPolicies.member
            @set 'term_policy_brief', asg_data.TerminationPolicies.member.join(" > ")

        if not @isAppEdit
            @set 'lcName',   asg_data.LaunchConfigurationName
            @set 'cooldown', asg_data.DefaultCooldown
            @set 'healCheckType', asg_data.HealthCheckType
            @set 'healthCheckGracePeriod', asg_data.HealthCheckGracePeriod

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

            policies.push policy


        @set 'policies', _.sortBy(policies, "name")

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


        # Get generated instances
        instance_count  = 0
        instance_groups = []
        instances_map   = {}

        if asg_data.Instances and asg_data.Instances.member
            instance_count = asg_data.Instances.member.length

            for instance, idx in asg_data.Instances.member
                ami =
                    status : if instance.HealthStatus is 'Healthy' then 'green' else 'red'
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
        null

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

  }

  new ASGModel()
