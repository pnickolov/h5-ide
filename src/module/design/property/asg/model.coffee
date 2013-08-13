#############################
#  View Mode for design/property/instance
#############################

define [ 'constant', 'jquery', 'MC' ], ( constant ) ->

  ASGConfigModel = Backbone.Model.extend {

    defaults :
      uid : null
      asg : null
      name : null
      has_sns_topic : null
      hasLaunchConfig : null
      notification_type : null

    initialize : ->
      null

    setUID : ( uid ) ->

      data =
        uid : uid

      this.set data
      null

    getASGDetailApp : ( uid ) ->

      this.set 'asg', MC.data.resource_list[MC.canvas_data.region][MC.canvas_data.component[uid].resource.AutoScalingGroupARN]


    getASGDetail : ( uid ) ->

      me = this

      if MC.canvas_data.component[uid].resource.LaunchConfigurationName

        this.set 'hasLaunchConfig', true

      asg = $.extend true, {}, MC.canvas_data.component[uid]

      if asg.resource.HealthCheckType is 'EC2'

        asg.resource.ec2 = true

      else if asg.resource.HealthCheckType is 'ELB'

        asg.resource.elb = true


      $.each MC.canvas_data.component, ( comp_uid, comp ) ->

        if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic

          me.set 'has_sns_topic', true

          return false

      policies = {}

      $.each MC.canvas_data.component, ( comp_uid, comp ) ->

        if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy

          tmp = {}

          tmp.adjusttype = comp.resource.AdjustmentType

          tmp.adjustment = comp.resource.ScalingAdjustment

          tmp.step = comp.resource.MinAdjustmentStep

          tmp.cooldown = comp.resource.Cooldown

          tmp.name = comp.resource.PolicyName

          $.each MC.canvas_data.component, ( c_uid, c ) ->

            if c.type is constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch

              actions = [c.resource.InsufficientDataActions, c.resource.OKAction, c.resource.AlarmActions]

              for action in actions

                if action[0] and action[0].split('.')[0][1...] is comp_uid

                  tmp.evaluation = c.resource.ComparisonOperator

                  tmp.metric = c.resource.MetricName

                  if action.length is 2

                    tmp.notify = true
                  else

                    tmp.notify = false

                  tmp.periods = c.resource.EvaluationPeriods

                  tmp.second = c.resource.Period

                  tmp.statistics = c.resource.Statistic

                  tmp.threshold = c.resource.Threshold

                  if c.resource.InsufficientDataActions.length > 0
                    tmp.trigger = 'INSUFFICIANT_DATA'
                  else if c.resource.OKAction.length > 0
                    tmp.trigger = 'OK'
                  else if c.resource.AlarmActions.length > 0
                    tmp.trigger = 'ALARM'

                  return false

          policies[comp_uid]  = tmp


          null

      nc_array = [false, false, false, false, false]

      $.each MC.canvas_data.component, ( comp_uid, comp ) ->

        if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration and comp.resource.AutoScalingGroupName.split('.')[0][1...] is uid

          if 'autoscaling:EC2_INSTANCE_LAUNCH' in comp.resource.NotificationType
            nc_array[0] = true

          if 'autoscaling:EC2_INSTANCE_LAUNCH_ERROR' in comp.resource.NotificationType

            nc_array[1] = true

          if 'autoscaling:EC2_INSTANCE_TERMINATE' in comp.resource.NotificationType

            nc_array[2] = true

          if 'autoscaling:EC2_INSTANCE_TERMINATE_ERROR' in comp.resource.NotificationType

            nc_array[3] = true

          if 'autoscaling:TEST_NOTIFICATION' in comp.resource.NotificationType

            nc_array[4] = true

          return false

      this.set 'notification_type', nc_array
      this.set 'policies', policies

      this.set 'asg', asg.resource

      this.set 'uid', uid

    setHealthCheckType : ( uid, type ) ->

      MC.canvas_data.component[uid].resource.HealthCheckType = type

      null

    setASGName : ( uid, name ) ->

      MC.canvas_data.component[uid].name = name
      MC.canvas_data.component[uid].resource.AutoScalingGroupName = name

      null

    setASGMin : ( uid, value ) ->


      MC.canvas_data.component[uid].resource.MinSize = value

      null

    setASGMax : ( uid, value ) ->

      MC.canvas_data.component[uid].resource.MaxSize = value

      null

    setASGDesireCapacity : ( uid, value ) ->

      MC.canvas_data.component[uid].resource.DesiredCapacity = value

      null

    setASGCoolDown : ( uid, value ) ->

      MC.canvas_data.component[uid].resource.DefaultCooldown = value

      null

    setHealthCheckGrace : ( uid, value ) ->

      MC.canvas_data.component[uid].resource.HealthCheckGracePeriod = value

      null

    setSNSOption : ( uid, check_array ) ->

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

        MC.canvas_data.component[nc_uid] = new_notification

      else

        $.each MC.canvas_data.component, ( comp_uid, comp ) ->

          if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration and comp.resource.AutoScalingGroupName.split('.')[0][1...] is uid

            delete MC.canvas_data.component[comp_uid]

            return false

      #if new_notification.resource.TopicARN and endpoint

        #$.each MC.canvas_data.component, ( comp_uid, comp ) ->

          #if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription and comp.resource.AutoScalingGroupName.split('.')[0][1...] is uid

          #  null
      null

    setTerminatePolicy : ( uid, policies ) ->

      current_policies = []

      for policy in policies

        if policy.checked

          current_policies.push policy.name

      MC.canvas_data.component[uid].resource.TerminationPolicies = current_policies

      null

    setPolicy : ( uid, policy_detail ) ->

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

      if policy_detail.adjustment is 'PercentChangeInCapacity'

        if not policy_detail.step

          policy_detail.step = 1

        policy_comp.resource.MinAdjustmentStep = policy_detail.step

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

        topic_uid = null

        sub_existing = false

        $.each MC.canvas_data.component, ( comp_uid, comp ) ->

          if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription

            sub_existing = true

          if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic

            topic_uid = comp.uid

          null

        if topic_uid

          if not sub_existing

            topic_ref = '@' + topic_uid + '.resource.TopicArn'

            topic_in_policy_existing = false

            $.each MC.canvas_data.component, ( comp_uid, comp ) ->

              if comp.type is constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch and (topic_ref in comp.resource.OKAction or topic_ref in comp.resource.InsufficientDataActions or topic_ref in comp.resource.AlarmActions)

                topic_in_policy_existing = true

                return false

            if not topic_in_policy_existing

              delete MC.canvas_data.component[topic_uid]


      MC.canvas_data.component[policy_uid] = policy_comp

      MC.canvas_data.component[cw_uid] = cw_comp



      null

    delPolicy : ( uid ) ->

      $.each MC.canvas_data.component, ( comp_uid, comp ) ->

          if comp.type is constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch and comp.name is MC.canvas_data.component[uid].name + '-alarm'

            delete MC.canvas_data.component[comp.uid]
            delete MC.canvas_data.component[uid]
            return false

  }

  model = new ASGConfigModel()

  return model
