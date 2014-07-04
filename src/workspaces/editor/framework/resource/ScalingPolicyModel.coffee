
define [ "../ResourceModel", "../ComplexResModel", "constant" ], ( ResourceModel, ComplexResModel, constant ) ->

  Model = ComplexResModel.extend {
    type : constant.RESTYPE.SP

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

    isVisual: () -> false

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

    isNotificate: -> @get 'sendNotification'

    getCost : ( priceMap, currency )->

      alarmData = @get("alarmData")

      period = parseInt( alarmData.period, 10 )
      if not ( period <= 300 and alarmData.namespace is "AWS/AutoScaling" )
        return null

      for p in priceMap.cloudwatch.types
        if p.ec2Monitoring
          fee = parseFloat( p.ec2Monitoring[ currency], 10 ) || 0
          break

      if fee and @__asg
        asgSize = if Design.instance().modeIsStack() then @__asg.get("minSize") else @__asg.get("capacity")

        fee = Math.round(fee / 7 * 1000) / 1000

        return {
          resource    : @get("name") + "-alarm"
          type        : "CloudWatch"
          fee         : fee
          formatedFee : fee + "/mo"
        }
      null

    setTopic: ( appId, name ) ->
      TopicModel = Design.modelClassForType( constant.RESTYPE.TOPIC )
      TopicModel.get( appId, name ).assignTo @

    removeTopic: ->
      @connections('TopicUsage')[ 0 ]?.remove()

    getTopic: () -> @connectionTargets('TopicUsage')[ 0 ]

    getTopicName: () -> @getTopic()?.get 'name'

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
          Cooldown             : @get("cooldown")
          AutoScalingGroupName : @__asg.createRef( "AutoScalingGroupName" )
          AdjustmentType       : @get("adjustmentType")
          # Correct old wrong json
          MinAdjustmentStep    : if @get("adjustmentType") is 'PercentChangeInCapacity' then @get("minAdjustStep") else ''


      alarmData = @get("alarmData")

      act_alarm = act_insuffi = act_ok = []
      action_arry = [ @createRef( "PolicyARN") ]

      if @get("sendNotification")
        # Ensure there's a SNS_Topic
        topic = @getTopic()
        if topic
          action_arry.push( topic.createRef( "TopicArn" ) )

      if @get("state") is "ALARM"
        act_alarm = action_arry
      else if @get("state") is "INSUFFICIANT_DATA"
        act_insuffi = action_arry
      else
        act_ok = action_arry

      alarm =
        name : @get("name") + "-alarm"
        type : constant.RESTYPE.CW
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

    handleTypes : [ constant.RESTYPE.SP, constant.RESTYPE.CW ]

    deserialize : ( data, layout_data, resolve ) ->

      if data.type is constant.RESTYPE.CW

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
            topic = resolve( MC.extractID(i) )
            sendNotification = true

        topic?.assignTo policy



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

