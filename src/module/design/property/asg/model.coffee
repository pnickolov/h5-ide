#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant', 'Design' ], ( PropertyModel, constant, Design ) ->

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

      component = Design.instance().component( uid )


      typeLC = constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      typeNoti = constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration
      typeSub = constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription
      typePolicy = constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy
      typeCWatch = constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch

      LCS = component.getFromStorage typeLC
      Noti = component.getFromStorage typeNoti
      Policy = component.getFromStorage typePolicy

      if LCS.length
        @set 'hasLaunchConfig', true

      conns = component.connections()

      hasElb = _.some conns, ( conn ) ->
        if conn.type is 'ElbAsso'
          true

      if hasElb
        @set 'has_elb', true


      policies = {}
      nc_array = [false, false, false, false, false]

      SubModel = Design.modelClassForType( typeSub )
      allSub = SubModel.allObjects()

      if allSub.length
        @set "has_sns_topic", true

      Noti.each ( model ) ->
        type = model.get 'NotificationType'

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

      Policy.each ( model ) ->

        policies[ model.id ] = tmp =
          adjusttype : model.get 'AdjustmentType'
          adjustment : model.get 'ScalingAdjustment'
          step       : model.get 'MinAdjustmentStep'
          cooldown   : model.get 'Cooldown'
          name       : model.get 'PolicyName'
          uid        : model.id

        alarmname = "#{model.get 'name'}-alarm"

        CWatch = model.getFromStorage typeCWatch

        CWatch.each ( c ) ->
          actions = [c.get 'InsufficientDataActions', c.get 'OKAction', c.get 'AlarmActions']

          for action in actions
            if action[0] and action[0].indexOf( c.id ) != -1
              tmp.evaluation = c.get 'ComparisonOperator'
              tmp.metric     = c.get 'MetricName'
              tmp.notify     = action.length is 2
              tmp.periods    = c.get 'EvaluationPeriods'
              tmp.second     = c.get 'Period'
              tmp.statistics = c.get 'Statistic'
              tmp.threshold  = c.get 'Threshold'

              if c.get( 'InsufficientDataActions' ).length > 0
                tmp.trigger = 'INSUFFICIANT_DATA'
              else if c.get( 'OKAction' ).length > 0
                tmp.trigger = 'OK'
              else if c.get ( 'AlarmActions' ).length > 0
                tmp.trigger = 'ALARM'

              break


      lc_comp = LCS.first()
      @set 'detail_monitor', if lc_comp then "" + lc_comp.resource.InstanceMonitoring is 'true' else false

      @set 'notification_type', nc_array
      @set 'policies', policies
      @set 'asg', component.toJSON()
      @set 'uid', uid


    setHealthCheckType : ( type ) ->

      uid = @get 'uid'

      Design.instance().component( uid ).set( "HealthCheckType", type )

      null

    setASGName : ( name ) ->

      uid = @get 'uid'

      component = Design.instance().component( uid )

      component.set { name: name, AutoScalingGroupName: name }

      # canvas update will be bind to the change event of the corresponding model
      MC.canvas.update uid, 'text', 'name', name

      # update extended asg
      _.each MC.canvas_data.layout.component.group, ( group, id ) ->
        if group.originalId is uid
          MC.canvas.update id, 'text', 'name', name

      null

    setASGMin : ( value ) ->

      uid = @get 'uid'

      Design.instance().component( uid ).set( "MinSize", value )

      null

    setASGMax : ( value ) ->

      uid = @get 'uid'

      Design.instance().component( uid ).set( "MaxSize", value )

      null

    setASGDesireCapacity : ( value ) ->

      uid = @get 'uid'

      Design.instance().component( uid ).set( "DesiredCapacity", value )

      null

    setASGCoolDown : ( value ) ->

      uid = @get 'uid'

      Design.instance().component( uid ).set( "DefaultCooldown", value )

      null

    setHealthCheckGrace : ( value ) ->

      uid = @get 'uid'

      Design.instance().component( uid ).set( "HealthCheckGracePeriod", value )

      null

    setSNSOption : ( check_array ) ->

      uid = @get 'uid'
      component = Design.instance().component( uid )

      typeNoti = constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration
      typeTopic = constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic

      Noti = component.getFromStorage typeNoti

      if true in check_array

        notification_type = []

        new_notification = null

        nc_uid = null



        if Noti.length
          new_notification = $.extend true, {}, comp
          nc_uid = new_notification.uid


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

        topicModel = Design.modelClassForType( typeTopic )
        topic = topicModel.allObjects()[ 0 ]

        if topic
          topic_arn = '@' + topic.id + '.resource.TopicArn'
        else
          topic_comp = $.extend true, {}, MC.canvas.SNS_TOPIC_JSON.data

          topic_uid = MC.guid()

          topic_comp.uid = topic_uid

          topic_comp.name = topic_comp.resource.Name = topic_comp.resource.DisplayName = 'sns-topic'

          topic_arn = '@' + topic_uid + '.resource.TopicArn'

          MC.canvas_data.component[topic_uid] = topic_comp

        new_notification.resource.TopicARN = topic_arn

        @createNotification new_notification

      else

        Noti.each ( model ) ->
          model.remove()

        res = this.checkTopicDependency()

        if res[0] and not res[1]
          Design.instance().component( res[2] ).remove()

      null

    createNotification: ( data ) ->
      Model = Design.modelClassForType( AWS_AutoScaling_NotificationConfiguration )
      resolve = Design.instance().component

      attr =
        id           : data.uid
        name         : data.name

      for key, value of data.resource
        attr[ key ] = value

      asgUid = MC.extractID attr.AutoScalingGroupName
      asg = resolve asgUid

      topicUid = MC.extractID attr.TopicARN
      topic = resolve topicUid

      model = new Model( attr )

      asg.addToStorage model
      model.addToStorage topic

    setTerminatePolicy : ( policies ) ->

      uid = this.get 'uid'
      component = Design.instance().component( uid )

      current_policies = []

      for policy in policies

        if policy.checked

          current_policies.push policy.name

      component.set 'TerminationPolicies', current_policies

      null

    isDupPolicyName : ( policy_uid, name ) ->

      uid = @get 'uid'

      SPModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy )
      AllSP = SPModel.allObjects()

      _.some AllSP, ( model ) ->
        if model.id isnt policy_uid and model.get( 'name' ) is name and MC.extractID( model.get 'AutoScalingGroupName' ) is uid
          return true

    setPolicy : ( policy_detail ) ->

      uid = @get 'uid'

      if policy_detail.uid
        policy_uid = policy_detail.uid
        policy_comp = Design.instance().component( policy_uid ).toJSON()
        cw_name = policy_comp.get 'name' + "-alarm"
      else
        policy_uid  = MC.guid()
        policy_comp = {}
        policy_comp.uid = policy_uid

        # Hack, set the uid here.
        # So that view knows the newly added item's uid
        policy_detail.uid = policy_uid

        cw_uid  = MC.guid()
        cw_comp = {}

      topic_arn  = null

      TopicModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic )
      WatchModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch )

      allTopic = TopicModel.allObjects()
      allWatch = WatchModel.allObjects()

      _.each allTopic, ( model ) ->
        topic_arn = "@#{model.id}.resource.TopicArn"
        null

      _.each allWatch, ( model ) ->
        if model.get( 'name' ) is cw_name
          cw_comp = model.toJSON()
          cw_uid  = model.id

      policy_res = policy_comp.resource
      cw_res     = cw_comp.resource

      # Set Policy Component
      policy_comp.name             = policy_detail.name
      policy_comp.AdjustmentType    = policy_detail.adjusttype
      policy_comp.Cooldown          = policy_detail.cooldown
      policy_comp.PolicyName        = policy_detail.name
      policy_comp.ScalingAdjustment = policy_detail.adjustment

      policy_comp.AutoScalingGroupName = "@#{uid}.resource.AutoScalingGroupName"

      if policy_detail.adjusttype is 'PercentChangeInCapacity'
        policy_comp.MinAdjustmentStep = policy_detail.step || 1

      # Set CloudWatch Component
      cw_comp.id  = cw_uid
      cw_comp.name = cw_res.AlarmName = policy_detail.name + '-alarm'

      cw_comp.ComparisonOperator = policy_detail.evaluation
      cw_comp.EvaluationPeriods  = policy_detail.periods
      cw_comp.MetricName         = policy_detail.metric
      cw_comp.Period             = policy_detail.second
      cw_comp.Statistic          = policy_detail.statistics
      cw_comp.Threshold          = policy_detail.threshold
      cw_comp.Dimensions         = [{name:"AutoScalingGroupName", value:policy_res.AutoScalingGroupName}]

      # Set trigger
      # Remove old trigger array
      cw_comp.AlarmActions = cw_res.InsufficientDataActions = cw_res.OKAction = []

      action = [ "@#{policy_uid}.resource.PolicyARN" ]

      switch policy_detail.trigger
        when 'ALARM'
          cw_comp.AlarmActions = action
        when 'INSUFFICIANT_DATA'
          cw_comp.InsufficientDataActions = action
        when 'OK'
          cw_comp.OKAction = action

      # Set SNS
      if policy_detail.notify
        # Create Topic
        if not topic_arn
          topic_comp = $.extend true, {}, MC.canvas.SNS_TOPIC_JSON.data
          topic_uid  = MC.guid()
          topic_comp.uid = topic_uid
          topic_comp.name = topic_comp.resource.Name = topic_comp.resource.DisplayName = 'sns-topic'
          topic_arn = "@#{topic_uid}.resource.TopicArn"

          MC.canvas_data.component[topic_uid] = topic_comp

        action.push topic_arn

      else

        res = this.checkTopicDependency()

        if res[0] and not res[1]

          delete MC.canvas_data.component[res[2]]
          Design.instance().component( res[2] ).remove()

      policyModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy )
      CWatchModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch )

      new policyModel policy_comp
      new CWatchModel cw_comp

      @attributes.policies[policy_uid] = policy_detail
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

      TopicModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic )
      SubModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription )
      NotiModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration )
      WatchModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch )


      allTopic = TopicModel.allObjects()
      allSub = SubModel.allObjects()
      allNoti = NotiModel.allObjects()
      allWatch = WatchModel.allObjects()

      if allTopic.length
        topic_uid = allTopic[0].id

      if allSub.length or allNoti.length
        dependent = true

      if topic_uid and not dependent

        topic_ref = '@' + topic_uid + '.resource.TopicArn'

        $.each MC.canvas_data.component, ( comp_uid, comp ) ->

        _.each allWatch, ( model ) ->

          if topic_ref in model.get 'OKAction' or topic_ref in model.get 'InsufficientDataActions' or topic_ref in model.get 'AlarmActions'

            dependent = true

            return false

      if topic_uid

        return [true, dependent, topic_uid]

      else

        return [false, dependent, topic_uid]

  }

  new ASGConfigModel()
