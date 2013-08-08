#############################
#  View Mode for design/property/instance
#############################

define [ 'jquery' ], () ->

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

    setSNSOption : ( check_array, endpoint ) ->

      if true in check_array

        notification_type = []
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

      null

  }

  model = new ASGConfigModel()

  return model
