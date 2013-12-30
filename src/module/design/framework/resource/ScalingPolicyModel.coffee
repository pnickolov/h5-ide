
define [ "../ResourceModel", "constant" ], ( ResourceModel, constant ) ->

  Model = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy

    defualts : ()->
      cooldown       : ""
      minAdjustStep  : ""
      adjustment     : "-1"
      adjustmentType : ""

      state            : "ALARM"
      sendNotification : false

      alarmData      : {
        metricName         : "CPUUtilization"
        comparisonOperator : ">="
        evaluationPeriods  : "2"
        period             : "300"
        statistic          : "Average"
        threshold          : "10"
        unit               : ""
        appId              : ""
      }

  }, {

    handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy, constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch ]

    deserialize : ( data, layout_data, resolve ) ->

      if data.type is constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch

        alarmData = {
          name  : data.name
          appId : data.resource.AlarmArn
          comparisonOperator : data.resource.ComparisonOperator
          evaluationPeriods  : data.resource.EvaluationPeriods
          metricName         : data.resource.MetricName
          period             : data.resource.Period
          statistic          : data.resource.Statistic
          threshold          : data.resource.Threshold
          unit               : data.resource.Unit
        }

        refArray = []
        if data.resource.AlarmActions.length
          state = "ALARM"
          refArray.push data.resource.AlarmActions[0]
          refArray.push data.resource.AlarmActions[1]

        if data.resource.OKAction.length
          state = "OK"
          refArray.push data.resource.OKAction[0]
          refArray.push data.resource.OKAction[1]

        if data.resource.InsufficientDataActions.length
          state = "INSUFFICIANT_DATA"
          refArray.push data.resource.InsufficientDataActions[0]
          refArray.push data.resource.InsufficientDataActions[1]

        sendNotification = false
        for i in refArray
          if not i then continue
          if i.indexOf("PolicyARN")
            policy = resolve( MC.extractID(i) )
          else if i.indexOf("TopicArn")
            sendNotification = true

        policy.set {
          "alarmData" : alarmData
          "sendNotification" : sendNotification
          "state" : state
        }

      else
        policy = new Model({
          id    : data.uid
          name  : data.name
          appId : data.resource.PolicyARN

          cooldown       : data.resource.Cooldown
          minAdjustStep  : data.resource.MinAdjustmentStep
          adjustment     : data.resource.ScalingAdjustment
          adjustmentType : data.resource.AdjustmentType
        })

        resolve( MC.extractID( data.resource.AutoScalingGroupName) ).addScalingPolicy( policy )
      null
  }

  Model

