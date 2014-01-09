#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant', 'Design' ], ( PropertyModel, constant, Design ) ->

  ASGConfigModel = PropertyModel.extend {

    init : ( uid ) ->
      component = Design.instance().component( uid )

      if component.type is "ExpandedAsg"
        component = component.get("originalAsg")

      data = component.toJSON()
      data.uid = uid
      @set( data )

      lc = component.get("lc")

      if not lc
        @set "emptyAsg", true
        return

      @set "has_elb", !!component.get("lc").connections("ElbAmiAsso").length
      @set "isEC2HealthCheck", component.isEC2HealthCheckType()
      @set 'detail_monitor', !!lc.get( 'monitoring' )

      # Notification
      n = component.getNotification()
      @set "notification", n
      @set "has_notification", n.instanceLaunch or n.instanceLaunchError or n.instanceTerminate or n.instanceTerminateError or n.test
      @set "has_sns_sub", !!(Design.modelClassForType(constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription).allObjects().length)

      # Policies
      @set "policies", _.map data.policies, (p)-> $.extend true, {}, p.attributes
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
      Design.instance().component( @get("uid") ).setNotification( notification )

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
      count = Design.instance().component( @get("uid") ).get("policies").length + 1
      "#{@attributes.name}-policy-#{count}"

    getPolicy : ( uid )->
      $.extend true, {}, Design.instance().component( uid ).attributes

    setPolicy : ( policy_detail ) ->
      asg = Design.instance().component( @get("uid") )

      if not policy_detail.uid
        PolicyModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy )
        policy = new PolicyModel( policy_detail )
        asg.addScalingPolicy( policy )

        policy_detail.uid = policy.id
        @get("policies").push( policy.toJSON() )

      else
        policy = Design.instance().component( policy_detail.uid )
        policy.set policy_detail
      null
  }

  new ASGConfigModel()
