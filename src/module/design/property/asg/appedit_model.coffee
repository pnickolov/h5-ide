#############################
#  View(UI logic) for design/property/instacne
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

        @getASGDetailAppEdit uid

    getASGDetailAppEdit : ( uid ) ->

          asg_comp = MC.canvas_data.component[uid]
          asg_data = MC.data.resource_list[MC.canvas_data.region][asg_comp.resource.AutoScalingGroupARN]

          if not asg_data
            this.set 'asg', null
            this.set 'asg_name', asg_comp.name
            return

          asg = $.extend true, {}, asg_data

          asg.TerminationPolicies = asg.TerminationPolicies.member

          this.set 'asg', asg


          policies = {}

          $.each MC.canvas_data.component, ( comp_uid, comp ) ->

            if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy

              app_comp = MC.data.resource_list[MC.canvas_data.region][comp.resource.PolicyARN]
              tmp = {}

              tmp.adjusttype = app_comp.AdjustmentType

              tmp.adjustment = app_comp.ScalingAdjustment

              tmp.step = app_comp.MinAdjustmentStep

              tmp.cooldown = app_comp.Cooldown

              tmp.name = app_comp.PolicyName

              $.each MC.canvas_data.component, ( c_uid, c ) ->

                if c.type is constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch and c.name is MC.canvas_data.component[comp_uid].name + '-alarm'

                  app_cw = MC.data.resource_list[MC.canvas_data.region][c.resource.AlarmArn]

                  actions = [app_cw.InsufficientDataActions, app_cw.OKActions, app_cw.AlarmActions]

                  for action in actions

                    if action

                      for act in action.member

                        if act is app_comp.PolicyARN

                          tmp.evaluation = app_cw.ComparisonOperator

                          tmp.metric = app_cw.MetricName

                          if action.length is 2

                            tmp.notify = true
                          else

                            tmp.notify = false

                          tmp.periods = app_cw.EvaluationPeriods

                          tmp.second = app_cw.Period

                          tmp.statistics = app_cw.Statistic

                          tmp.threshold = app_cw.Threshold

                          if app_cw.InsufficientDataActions and app_cw.InsufficientDataActions.length > 0
                            tmp.trigger = 'INSUFFICIANT_DATA'
                          else if app_cw.OKActions and app_cw.OKActions.length > 0
                            tmp.trigger = 'OK'
                          else if app_cw.AlarmActions and app_cw.AlarmActions.length > 0
                            tmp.trigger = 'ALARM'

                      return false

              policies[comp_uid]  = tmp

              null

          this.set 'policies', policies

          notifications = MC.data.resource_list[MC.canvas_data.region].NotificationConfigurations

          nc_array = [false, false, false, false, false]

          if notifications

            $.each notifications, ( idx, nc ) ->

              if nc.AutoScalingGroupName is asg.AutoScalingGroupName

                if nc.NotificationType is 'autoscaling:EC2_INSTANCE_LAUNCH'
                  nc_array[0] = true

                if nc.NotificationType is 'autoscaling:EC2_INSTANCE_LAUNCH_ERROR'
                  nc_array[1] = true

                if nc.NotificationType is 'autoscaling:EC2_INSTANCE_TERMINATE'
                  nc_array[2] = true

                if nc.NotificationType is 'autoscaling:EC2_INSTANCE_TERMINATE_ERROR'
                  nc_array[3] = true

                if nc.NotificationType is 'autoscaling:TEST_NOTIFICATION'
                  nc_array[4] = true

              null

          if true in nc_array
            this.set 'sendNotify', true
          else

            this.set 'sendNotify', false
          this.set 'notifies', nc_array

          instance_count = 0
          if asg.Instances

            instance_count = asg.Instances.member.length

          instances_display = []
          subnets = {}

          if asg.Instances

            $.each asg.Instances.member, ( idx, instance ) ->

              tmp = {}

              if instance.HealthStatus is 'Healthy'

                tmp.status = 'green'
              else
                tmp.status = 'red'

              tmp.name = instance.InstanceId

              if subnets[instance.AvailabilityZone]

                subnets[instance.AvailabilityZone].push tmp
              else
                subnets[instance.AvailabilityZone] = [tmp]


              null

          for k, v of subnets

            tmp = {}

            tmp.name = k
            tmp.instances = v

            instances_display.push tmp

          this.set 'subnets', instances_display
          this.set 'instance_count', instance_count

  }

  new ASGConfigModel()
