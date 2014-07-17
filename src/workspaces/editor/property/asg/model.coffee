#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant', 'Design' ], ( PropertyModel, constant, Design ) ->

  ASGConfigModel = PropertyModel.extend {

    init : ( uid ) ->
      component = Design.instance().component( uid )

      if component.type is "ExpandedAsg"
        component = component.get("originalAsg")
        uid = component.id

      data = component?.toJSON()
      data.uid = uid
      @set( data )

      lc = component.getLc()

      if not lc
        @set "emptyAsg", true
        return

      @set "has_elb", !!lc.connections("ElbAmiAsso").length
      @set "isEC2HealthCheck", component.isEC2HealthCheckType()

      # Notification
      n = component.getNotification()
      @set "notification", n
      @set "has_notification", n.instanceLaunch or n.instanceLaunchError or n.instanceTerminate or n.instanceTerminateError or n.test

      @notiObject = component.getNotiObject()
      # Policies
      @set "policies", _.map data.policies, (p) ->
        data = $.extend true, {}, p.attributes
        data.alarmData.period = Math.round( data.alarmData.period / 60 )
        data

      null

    setHealthCheckType : ( type ) ->
      Design.instance().component( @get("uid") ).set( "healthCheckType", type )

    setASGMin : ( value ) ->
      Design.instance().component( @get("uid") ).set( "minSize", value )

    setASGMax : ( value ) ->
      Design.instance().component( @get("uid") ).set( "maxSize", value )

    setASGDesireCapacity : ( value ) ->
      Design.instance().component( @get("uid") ).set( "capacity", value )

    setASGCoolDown : ( value ) ->
      Design.instance().component( @get("uid") ).set( "cooldown", value )

    setHealthCheckGrace : ( value ) ->
      Design.instance().component( @get("uid") ).set( "healthCheckGracePeriod", value )

    setNotification : ( notification )->
      n = Design.instance().component( @get("uid") ).setNotification( notification )
      @notiObject = n
      null

    removeTopic: ->
      n = Design.instance().component( @get("uid") ).setNotification( notification )
      n?.removeTopic()


    getNotificationTopicName: () ->
      Design.instance().component( @get("uid") ).getNotificationTopicName()

    setNotificationTopic: ( appId, name ) ->
      Design.instance().component( @get("uid") ).setNotificationTopic( appId, name )


    setTerminatePolicy : ( policies ) ->
      Design.instance().component( @get("uid") ).set("terminationPolicies", policies)
      @set "terminationPolicies", policies
      null

    delPolicy : ( uid ) ->
      Design.instance().component( uid ).remove()
      null

    isDupPolicyName : ( policy_uid, name ) ->
      _.some Design.instance().component( @get("uid") ).get("policies"), ( p ) ->
        if p.id isnt policy_uid and p.get( 'name' ) is name
          return true

    defaultScalingPolicyName : () ->
      component = Design.instance().component( @get("uid") )
      if component.type is "ExpandedAsg"
        component = component.get("originalAsg")
      policies = component.get("policies")
      count = policies.length
      name = "#{@attributes.name}-policy-#{count}"
      currentNames = _.map policies, ( policy ) ->
        policy.get 'name'

      while name in currentNames
        name = "#{@attributes.name}-policy-#{++count}"
      name


    getPolicy : ( uid )->
      data = $.extend true, {}, Design.instance().component( uid ).attributes
      data.alarmData.period = Math.round( data.alarmData.period / 60 )
      data

    setPolicy : ( policy_detail ) ->
      asg = Design.instance().component( @get("uid") )
      if asg.type is "ExpandedAsg"
        asg = asg.get('originalAsg')

      if not policy_detail.uid
        PolicyModel = Design.modelClassForType( constant.RESTYPE.SP )
        policy = new PolicyModel( policy_detail )
        asg.addScalingPolicy( policy )

        policy_detail.uid = policy.id
        @get("policies").push( policy.toJSON() )

      else
        policy = Design.instance().component( policy_detail.uid )
        alarmData = policy_detail.alarmData
        policy.setAlarm( alarmData )
        delete policy_detail.alarmData
        policy.set policy_detail
        policy_detail.alarmData = alarmData

      if policy_detail.sendNotification and policy_detail.topic
        policy.setTopic policy_detail.topic.appId, policy_detail.topic.name


      null
  }

  new ASGConfigModel()
