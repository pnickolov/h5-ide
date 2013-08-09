#############################
#  View Mode for design/property/instance
#############################

define [ 'constant', 'jquery', 'MC' ], ( constant ) ->

  ASGConfigModel = Backbone.Model.extend {

    defaults :
      uid : null
      asg : null

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

        this.set 'uid', uid

    setSNSOption : ( uid, check_array, endpoint ) ->

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

          new_notification.uid = nc_uid

          new_notification = $.extend true, {}, MC.canvas.ASL_NC_JSON.data

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

      null

  }

  model = new ASGConfigModel()

  return model
