#############################
#  View Mode for design/property/instance
#############################

define [ 'constant', 'jquery', 'MC' ], ( constant ) ->

  ASGConfigModel = Backbone.Model.extend {

    defaults :
      uid : null
      asg : null
      name : null

      hasLaunchConfig : null

    initialize : ->
      null

    setUID : ( uid ) ->

      data =
        uid : uid

      this.set data
      null

    getASGDetail : ( uid ) ->

      if MC.canvas_data.component[uid].resource.LaunchConfigurationName

        this.set 'hasLaunchConfig', true

      asg = $.extend true, {}, MC.canvas_data.component[uid]

      if asg.resource.HealthCheckType is 'EC2'

        asg.resource.ec2 = true

      else if asg.resource.HealthCheckType is 'ELB'

        asg.resource.elb = true

      this.set 'asg', asg

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

  }

  model = new ASGConfigModel()

  return model
