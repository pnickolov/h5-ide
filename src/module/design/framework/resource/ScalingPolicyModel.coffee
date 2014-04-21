
define [ "../ResourceModel", "constant" ], ( ResourceModel, constant ) ->

  Model = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy

    defaults : ()->
      cooldown       : ""
      minAdjustStep  : ""
      adjustment     : "-1"
      adjustmentType : "ChangeInCapacity"

      state            : "ALARM"
      sendNotification : false

      alarmData      : {
        id                 : MC.guid()
        alarmName          : ""
        namespace          : "AWS/AutoScaling"
        metricName         : "CPUUtilization"
        comparisonOperator : ">="
        evaluationPeriods  : "2"
        period             : "300"
        statistic          : "Average"
        threshold          : "10"
        unit               : ""
        appId              : ""
      }

    constructor : ( attribute, option )->
      defaults  = this.defaults()
      attribute.alarmData = $.extend defaults.alarmData, attribute.alarmData
      ResourceModel.call( this, attribute, option )

    setAlarm : ( alarmData )->
      @set "alarmData", $.extend {
        id        : @attributes.alarmData.id
        namespace : "AWS/AutoScaling"
        unit      : ""
        appId     : @attributes.alarmData.appId
        alarmName : @attributes.alarmData.alarmName
      }, alarmData
      null


    getCost : ( priceMap, currency )->

      alarmData = @get("alarmData")

      period = parseInt( alarmData.period, 10 )
      if not ( period <= 300 and alarmData.namespace is "AWS/AutoScaling" )
        return null

      for p in priceMap.cloudwatch.types
        if p.ec2Monitoring
          fee = parseFloat( p.ec2Monitoring[ currency], 10 ) || 0
          break

      if fee
        asgSize = if Design.instance().modeIsStack() then @__asg.get("minSize") else @__asg.get("capacity")

        fee = Math.round(fee / 7 * 1000) / 1000

        return {
          resource    : @get("name") + "-alarm"
          type        : "CloudWatch"
          fee         : fee
          formatedFee : fee + "/mo"
        }
      null

    serialize : ()->

      if not @__asg
        console.warn "ScalingPolicy has no attached asg when serializing."
        return

      policy =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          ScalingAdjustment    : @get("adjustment")
          PolicyName           : @get("name")
          PolicyARN            : @get("appId")
          MinAdjustmentStep    : @get("minAdjustStep")
          Cooldown             : Math.round( @get("cooldown") / 60 ) * 60
          AutoScalingGroupName : @__asg.createRef( "AutoScalingGroupName" )
          AdjustmentType       : @get("adjustmentType")


      alarmData = @get("alarmData")

      act_alarm = act_insuffi = act_ok = []
      action_arry = [ @createRef( "PolicyARN") ]

      if @get("sendNotification")
        # Ensure there's a SNS_Topic
        TopicModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic )
        action_arry.push( TopicModel.ensureExistence().createRef( "TopicArn" ) )

      if @get("state") is "ALARM"
        act_alarm = action_arry
      else if @get("state") is "INSUFFICIANT_DATA"
        act_insuffi = action_arry
      else
        act_ok = action_arry

      alarm =
        name : @get("name") + "-alarm"
        type : constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch
        uid  : alarmData.id
        resource :
          AlarmArn  : alarmData.appId
          AlarmName : alarmData.alarmName or ( @get("name") + "-alarm" )
          ComparisonOperator : alarmData.comparisonOperator
          EvaluationPeriods  : alarmData.evaluationPeriods
          MetricName         : alarmData.metricName
          Namespace          : alarmData.namespace
          Period             : Math.round( alarmData.period / 60 ) * 60
          Statistic          : alarmData.statistic
          Threshold          : alarmData.threshold
          Unit               : alarmData.unit
          Dimensions         : [{
            name  : "AutoScalingGroupName"
            value : @__asg.createRef( "AutoScalingGroupName" )
          }]
          AlarmActions            : act_alarm
          InsufficientDataActions : act_insuffi
          OKAction                : act_ok

      [ { component : policy }, { component : alarm } ]

  }, {

    handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy, constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch ]

    diffJson : ( newData, oldData )->
      if not ( newData and oldData and _.isEqual( newData, oldData ) )
        asgId = (newData || oldData).resource
        asgId = asgId.AutoScalingGroupName || asgId.Dimensions[0].value
        asg   = Design.instance().component( MC.extractID( asgId ) )
        if asg
          return {
            id     : asgId
            type   : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
            name   : asg.get("name")
            change : "Update"
          }

      null

    deserialize : ( data, layout_data, resolve ) ->

      if data.type is constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch

        alarmData = {
          id                 : data.uid
          name               : data.name
          alarmName          : data.resource.AlarmName
          appId              : data.resource.AlarmArn
          comparisonOperator : data.resource.ComparisonOperator
          evaluationPeriods  : data.resource.EvaluationPeriods
          metricName         : data.resource.MetricName
          period             : data.resource.Period
          statistic          : data.resource.Statistic
          threshold          : data.resource.Threshold
          namespace          : data.resource.Namespace
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
          if i.indexOf("PolicyARN") != -1
            policy = resolve( MC.extractID(i) ) || new Backbone.Model()
          else if i.indexOf("TopicArn") != -1
            sendNotification = true

        if policy
          policy.set {
            "alarmData" : alarmData
            "sendNotification" : sendNotification
            "state" : state
          }

      else
        policy = new Model({
          id    : data.uid
          name  : data.resource.PolicyName or data.name
          appId : data.resource.PolicyARN

          cooldown       : data.resource.Cooldown
          minAdjustStep  : data.resource.MinAdjustmentStep
          adjustment     : data.resource.ScalingAdjustment
          adjustmentType : data.resource.AdjustmentType
        })

        asg = resolve( MC.extractID( data.resource.AutoScalingGroupName) )
        if asg then asg.addScalingPolicy( policy )
      null
  }

  Model

