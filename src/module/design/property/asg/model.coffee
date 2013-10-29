#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant' ], ( PropertyModel, constant ) ->

  ASGConfigModel = PropertyModel.extend {

    defaults :
      uid               : null
      asg               : null
      name              : null
      has_sns_topic     : null
      hasLaunchConfig   : null
      notification_type : null
      has_elb           : false
      detail_monitor    : false

    init : ( uid ) ->
      @set 'uid', uid
      @getASGDetail uid
      null

    getASGDetail : ( uid ) ->

      component = MC.canvas_data.component[uid]

      @set 'hasLaunchConfig', component.resource.LaunchConfigurationName.length > 0
      @set 'has_elb', component.resource.LoadBalancerNames.length > 0


      policies = {}
      nc_array = [false, false, false, false, false]


      for comp_uid, comp of MC.canvas_data.component
        if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription
          @set "has_sns_topic", true

        else if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration
          if comp.resource.AutoScalingGroupName.indexOf( uid ) is -1
            continue

          type = comp.resource.NotificationType

          if 'autoscaling:EC2_INSTANCE_LAUNCH' in type
            nc_array[0] = true

          if 'autoscaling:EC2_INSTANCE_LAUNCH_ERROR' in type
            nc_array[1] = true

          if 'autoscaling:EC2_INSTANCE_TERMINATE' in type
            nc_array[2] = true

          if 'autoscaling:EC2_INSTANCE_TERMINATE_ERROR' in type
            nc_array[3] = true

          if 'autoscaling:TEST_NOTIFICATION' in type
            nc_array[4] = true

          @set "has_notification", true

        else if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy

          if comp.resource.AutoScalingGroupName.indexOf( uid ) is -1
            continue

          policies[comp_uid] = tmp =
            adjusttype : comp.resource.AdjustmentType
            adjustment : comp.resource.ScalingAdjustment
            step       : comp.resource.MinAdjustmentStep
            cooldown   : comp.resource.Cooldown
            name       : comp.resource.PolicyName
            uid        : comp_uid

          alarmname = "#{comp.name}-alarm"

          for c_uid, c of MC.canvas_data.component
            if c.type isnt constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch
              continue

            if c.name isnt alarmname
              continue

            actions = [c.resource.InsufficientDataActions, c.resource.OKAction, c.resource.AlarmActions]

            for action in actions
              if action[0] and action[0].indexOf( comp_uid ) != -1
                tmp.evaluation = c.resource.ComparisonOperator
                tmp.metric     = c.resource.MetricName
                tmp.notify     = action.length is 2
                tmp.periods    = c.resource.EvaluationPeriods
                tmp.second     = c.resource.Period
                tmp.statistics = c.resource.Statistic
                tmp.threshold  = c.resource.Threshold

                if c.resource.InsufficientDataActions.length > 0
                  tmp.trigger = 'INSUFFICIANT_DATA'
                else if c.resource.OKAction.length > 0
                  tmp.trigger = 'OK'
                else if c.resource.AlarmActions.length > 0
                  tmp.trigger = 'ALARM'

                break

            break


      lc_uid  = MC.extractID( component.resource.LaunchConfigurationName )
      if lc_uid
        lc_comp = MC.canvas_data.component[ lc_uid ]
      @set 'detail_monitor', if lc_comp then lc_comp.resource.InstanceMonitoring is 'enabled' else false

      @set 'notification_type', nc_array
      @set 'policies', policies
      @set 'asg', component.resource
      @set 'uid', uid

    setHealthCheckType : ( type ) ->

      uid = @get 'uid'

      MC.canvas_data.component[uid].resource.HealthCheckType = type

      null

    setASGName : ( name ) ->

      uid = @get 'uid'

      MC.canvas_data.component[uid].name = name
      MC.canvas_data.component[uid].resource.AutoScalingGroupName = name

      MC.canvas.update uid, 'text', 'name', name

      # update extended asg
      _.each MC.canvas_data.layout.component.group, ( group, id ) ->
        if group.originalId is uid
          MC.canvas.update id, 'text', 'name', name

      null

    setASGMin : ( value ) ->

      uid = @get 'uid'

      MC.canvas_data.component[uid].resource.MinSize = value

      null

    setASGMax : ( value ) ->

      uid = @get 'uid'

      MC.canvas_data.component[uid].resource.MaxSize = value

      null

    setASGDesireCapacity : ( value ) ->

      uid = @get 'uid'

      MC.canvas_data.component[uid].resource.DesiredCapacity = value

      null

    setASGCoolDown : ( value ) ->

      uid = @get 'uid'

      MC.canvas_data.component[uid].resource.DefaultCooldown = value

      null

    setHealthCheckGrace : ( value ) ->

      uid = @get 'uid'

      MC.canvas_data.component[uid].resource.HealthCheckGracePeriod = value

      null

    setSNSOption : ( check_array ) ->

      uid = @get 'uid'

      if true in check_array

        notification_type = []

        new_notification = null

        nc_uid = null

        $.each MC.canvas_data.component, ( comp_uid, comp ) ->

          if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration and comp.resource.AutoScalingGroupName.split('.')[0][1...] is uid

            new_notification = $.extend true, {}, comp

            nc_uid = new_notification.uid

            return false



        if not new_notification

          nc_uid = MC.guid()

          new_notification = $.extend true, {}, MC.canvas.ASL_NC_JSON.data

          new_notification.uid = nc_uid

        if check_array[0]

          notification_type.push 'autoscaling:EC2_INSTANCE_LAUNCH'

        if check_array[1]

          notification_type.push 'autoscaling:EC2_INSTANCE_LAUNCH_ERROR'

        if check_array[2]

          notification_type.push 'autoscaling:EC2_INSTANCE_TERMINATE'

        if check_array[3]

          notification_type.push 'autoscaling:EC2_INSTANCE_TERMINATE_ERROR'

        if check_array[4]

          notification_type.push 'autoscaling:TEST_NOTIFICATION'

        new_notification.resource.NotificationType = notification_type

        new_notification.resource.AutoScalingGroupName = '@' + uid + '.resource.AutoScalingGroupName'

        topic_arn = null

        $.each MC.canvas_data.component, ( comp_uid, comp ) ->

          if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic

            topic_arn = '@' + comp_uid + '.resource.TopicArn'

            return false

        if not topic_arn

          topic_comp = $.extend true, {}, MC.canvas.SNS_TOPIC_JSON.data

          topic_uid = MC.guid()

          topic_comp.uid = topic_uid

          topic_comp.name = topic_comp.resource.Name = topic_comp.resource.DisplayName = 'sns-topic'

          topic_arn = '@' + topic_uid + '.resource.TopicArn'

          MC.canvas_data.component[topic_uid] = topic_comp

        new_notification.resource.TopicARN = topic_arn

        MC.canvas_data.component[nc_uid] = new_notification

      else

        $.each MC.canvas_data.component, ( comp_uid, comp ) ->

          if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration and comp.resource.AutoScalingGroupName.split('.')[0][1...] is uid

            delete MC.canvas_data.component[comp_uid]

            return false

        res = this.checkTopicDependency()

        if res[0] and not res[1]

          delete MC.canvas_data.component[res[2]]

      #if new_notification.resource.TopicARN and endpoint

        #$.each MC.canvas_data.component, ( comp_uid, comp ) ->

          #if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription and comp.resource.AutoScalingGroupName.split('.')[0][1...] is uid

          #  null
      null

    setTerminatePolicy : ( policies ) ->

      uid = this.get 'uid'

      current_policies = []

      for policy in policies

        if policy.checked

          current_policies.push policy.name

      MC.canvas_data.component[uid].resource.TerminationPolicies = current_policies

      null

    isDupPolicyName : ( policy_uid, name ) ->

      uid = @get 'uid'

      for comp_uid, comp of MC.canvas_data.component
        if comp_uid is policy_uid
          continue

        if comp.type isnt constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy
          continue

        if comp.name is name and MC.extractID( comp.resource.AutoScalingGroupName ) is uid
          return true

      false


    setPolicy : ( policy_detail ) ->

      uid = @get 'uid'

      policy_uid = null

      policy_comp = null

      cw_uid = null

      cw_comp = null

      if not policy_detail.uid

        policy_uid = MC.guid()

        policy_comp = $.extend true, {}, MC.canvas.ASL_SP_JSON.data

        policy_comp.uid = policy_uid

        cw_uid = MC.guid()

        cw_comp = $.extend true, {}, MC.canvas.CLW_JSON.data

        # Hack, set the uid here.
        # So that view knows the newly added item's uid
        policy_detail.uid = policy_uid

      else

        policy_uid = policy_detail.uid

        policy_comp = MC.canvas_data.component[policy_uid]

        $.each MC.canvas_data.component, ( comp_uid, comp ) ->

          if comp.type is constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch and comp.name is MC.canvas_data.component[policy_uid].name + '-alarm'

            cw_uid = comp.uid

            cw_comp = comp

            return false

      policy_comp.name = policy_detail.name

      policy_comp.resource.AdjustmentType = policy_detail.adjusttype

      policy_comp.resource.AutoScalingGroupName = '@' + uid + '.resource.AutoScalingGroupName'

      policy_comp.resource.Cooldown = policy_detail.cooldown

      policy_comp.resource.PolicyName = policy_detail.name

      if policy_detail.adjusttype is 'PercentChangeInCapacity'
        policy_comp.resource.MinAdjustmentStep = policy_detail.step || 1

      policy_comp.resource.ScalingAdjustment = policy_detail.adjustment



      cw_comp.uid = cw_uid

      cw_comp.name = cw_comp.resource.AlarmName = policy_detail.name + '-alarm'

      cw_comp.resource.ComparisonOperator = policy_detail.evaluation

      cw_comp.resource.Dimensions = [{name:"AutoScalingGroupName", value:policy_comp.resource.AutoScalingGroupName}]

      cw_comp.resource.EvaluationPeriods = policy_detail.periods

      cw_comp.resource.MetricName = policy_detail.metric

      cw_comp.resource.Namespace = 'AWS/AutoScaling'

      cw_comp.resource.Period = policy_detail.second

      if policy_detail.statistics
        cw_comp.resource.Statistic = policy_detail.statistics

      cw_comp.resource.Threshold = policy_detail.threshold

      #cw_comp.resource.Unit = "Seconds"

      policy_arn = '@' + policy_uid + '.resource.PolicyARN'

      topic_arn = null

      topic_existing = false

      $.each MC.canvas_data.component, ( comp_uid, comp ) ->

        if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic

          topic_existing = true

          topic_arn = '@' + comp_uid + '.resource.TopicArn'

          return false


      action = null

      switch policy_detail.trigger

        when 'ALARM'

          action = cw_comp.resource.AlarmActions

        when 'INSUFFICIANT_DATA'

          action = cw_comp.resource.InsufficientDataActions

        when 'OK'

          action = cw_comp.resource.OKAction

      action.splice(0,action.length)

      action.push policy_arn

      if policy_detail.notify

        if not topic_arn

          topic_comp = $.extend true, {}, MC.canvas.SNS_TOPIC_JSON.data

          topic_uid = MC.guid()

          topic_comp.uid = topic_uid

          topic_comp.name = topic_comp.resource.Name = topic_comp.resource.DisplayName = 'sns-topic'

          topic_arn = '@' + topic_uid + '.resource.TopicArn'

          MC.canvas_data.component[topic_uid] = topic_comp


        action.push topic_arn

      else

        # topic_uid = null

        # sub_existing = false

        # $.each MC.canvas_data.component, ( comp_uid, comp ) ->

        #   if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription

        #     sub_existing = true

        #   if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic

        #     topic_uid = comp.uid

        #   null

        # if topic_uid

        #   if not sub_existing

        #     topic_ref = '@' + topic_uid + '.resource.TopicArn'

        #     topic_in_policy_existing = false

        #     $.each MC.canvas_data.component, ( comp_uid, comp ) ->

        #       if comp.type is constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch and (topic_ref in comp.resource.OKAction or topic_ref in comp.resource.InsufficientDataActions or topic_ref in comp.resource.AlarmActions)

        #         topic_in_policy_existing = true

        #         return false

        res = this.checkTopicDependency()

        if res[0] and not res[1]

          delete MC.canvas_data.component[res[2]]


      MC.canvas_data.component[policy_uid] = policy_comp

      MC.canvas_data.component[cw_uid] = cw_comp

      this.attributes.policies[ policy_uid ] = policy_detail



      null

    defaultScalingPolicyName : () ->
      count = 1
      for uid, comp of MC.canvas_data.component
        if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy
          ++count

      "#{@attributes.asg.AutoScalingGroupName}-policy-#{count}" + ""

    delPolicy : ( uid ) ->

      $.each MC.canvas_data.component, ( comp_uid, comp ) ->

          if comp.type is constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch and comp.name is MC.canvas_data.component[uid].name + '-alarm'

            delete MC.canvas_data.component[comp.uid]
            delete MC.canvas_data.component[uid]
            return false

    checkTopicDependency :() ->

      topic_uid = null

      dependent = false

      $.each MC.canvas_data.component, ( comp_uid, comp ) ->

        if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic

          topic_uid = comp_uid

        if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription

          dependent = true

        if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration

          dependent = true

        null

      if topic_uid and not dependent

        topic_ref = '@' + topic_uid + '.resource.TopicArn'

        $.each MC.canvas_data.component, ( comp_uid, comp ) ->

          if comp.type is constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch and (topic_ref in comp.resource.OKAction or topic_ref in comp.resource.InsufficientDataActions or topic_ref in comp.resource.AlarmActions)

            dependent = true

            return false

      if topic_uid

        return [true, dependent, topic_uid]

      else

        return [false, dependent, topic_uid]

  }

  new ASGConfigModel()
