
define [ "../ResourceModel", "constant" ], ( ResourceModel, constant ) ->

  Model = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy

    defualts : ()->
      cooldown       : ""
      minAdjustStep  : ""
      adjustment     : "-1"
      adjustmentType : ""

      state          : "ALARM"

      alarmData      : {
        name               : ""
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

      policy = new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.PolicyARN

        cooldown       : data.resource.cooldown
        minAdjustStep  : data.resource.MinAdjustmentStep
        adjustment     : data.resource.ScalingAdjustment
        adjustmentType : data.resource.AdjustmentType
      })

      resolve( MC.extractID( data.resource.AutoScalingGroupName) ).addScalingPolicy( this )
      null
  }

  Model

