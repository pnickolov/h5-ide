
define [ "constant", "../ConnectionModel", "../ResourceModel", "component/sgrule/SGRulePopup" ], ( constant, ConnectionModel, ResourceModel, SGRulePopup )->

  # SgRuleLine is used to draw lines in canvas
  SgRuleLine = ConnectionModel.extend {

    constructor : ( p1Comp, p2Comp, attr, option ) ->
      console.assert( p1Comp isnt p2Comp, "Sgline should connect to different resources." )

      # Override the constructor to determine if the line should be created.
      # Using the `@setDestroyAfterInit()` has its limilation

      if not @assignCompsToPorts( p1Comp, p2Comp ) or not @shouldCreateLine()
        return

      ConnectionModel.call this, p1Comp, p2Comp, attr, option

    shouldCreateLine : ()->
      p1Comp = @port1Comp()
      p2Comp = @port2Comp()

      TYPE   = constant.AWS_RESOURCE_TYPE

      # There will never be sgline between two Elb.
      if p1Comp.type is p2Comp.type and p1Comp.type is TYPE.AWS_ELB
        return false

      # Sgline only exist when eni is not attached to the ami
      ami = @getTarget TYPE.AWS_EC2_Instance
      eni = @getTarget TYPE.AWS_VPC_NetworkInterface
      if eni
        attachs = eni.connectionTargets( "EniAttachment" )
        # Unattached Eni doesn't have SgLine.
        if attachs.length == 0 then return false
        if attachs.indexOf( ami ) >= 0 then return false

      # Hide sglist between lc and expandedasg
      expandAsg = @getTarget "ExpandedAsg"
      lc        = @getTarget TYPE.AWS_AutoScaling_LaunchConfiguration
      if expandAsg and lc and expandAsg.get("originalAsg").get("lc") is lc
        return false

      # If elb is internet-facing, don't show line.
      elb = @getTarget TYPE.AWS_ELB
      if elb and not elb.get("internal")
        return false

      true


    # validate() returns true if the line should still exist.
    validate : ( autoRemoveWhenFailValidatation )->
      # Only show sg line for inbound rules of elb
      result = true
      elb = @getTarget constant.AWS_RESOURCE_TYPE.AWS_ELB
      if elb
        elbSgMap  = {}
        hasInRule = false
        for sg in elb.connectionTargets( "SgAsso" )
          elbSgMap[ sg.id ] = sg

        for sg in @getOtherTarget( elb ).connectionTargets( "SgAsso" )
          for ruleset in sg.connections( "SgRuleSet" )
            target = ruleset.getOtherTarget( sg )
            if not elbSgMap[ target.id ] then continue

            if ruleset.hasRawRuleTo( elbSgMap[ target.id ] )
              hasInRule = true
              break

          if hasInRule then break

        if not hasInRule then result = false


      if not result and autoRemoveWhenFailValidatation
        @remove( { reason : "Validation Failed" } )

      result

    initialize : ( attributes, option )->
      # If the line is created by the user, we should a popup dialog to let
      # user add sgrule. And then immediately remove the sgline
      if option and option.createByUser
        new SGRulePopup( this.id )
        @setDestroyAfterInit()
      else if not @validate()
        @setDestroyAfterInit()
      null

    isRemovable : ()->
      SgRuleSetModel = Design.modelClassForType( "SgRuleSet" )
      allRuleSets = SgRuleSetModel.getRelatedSgRuleSets @port1Comp(), @port2Comp()

      groups = SgRuleSetModel.getGroupedObjFromRuleSets( allRuleSets )

      # Show the list of the sgrules that this line represent
      for group in groups
        group.content = MC.template.sgRuleList( group.rules )

      MC.template.groupedSgRuleListDelConfirm( groups )



    # If reason is not falsy, the sgline is removed by us, not by user.
    # If the sgline is removed by use, we need to remove all the rules
    # that are represented by this line.
    remove : ( reason )->
      ConnectionModel.prototype.remove.apply this, arguments

      if reason then return

      if @port1Comp().isRemoved() or @port2Comp().isRemoved() then return

      SgRuleSetModel = Design.modelClassForType( "SgRuleSet" )
      for rs in SgRuleSetModel.getRelatedSgRuleSets( @port1Comp(), @port2Comp() )
        rs.remove()
      null



    # This method is used by Asg to remove its expanded asg's sgline.
    silentRemove : ()->
      v = @__view
      if v then v.detach()

      ResourceModel.prototype.remove.apply( this, arguments )
      null


    type : "SgRuleLine"

    defaults :
      lineType : "sg"
      dashLine : true
      name     : "Security Group Rule"

    portDefs : [

      # Instance
      {
        port1 :
          name : "instance-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name : "instance-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      }
      {
        port1 :
          name : "instance-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name : "eni-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }
      {
        port1 :
          name : "instance-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name : "launchconfig-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      }
      {
        port1 :
          name : "instance-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name : "launchconfig-sg"
          type : "ExpandedAsg"
      }
      {
        port1 :
          name : "instance-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name : "elb-sg-in"
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
      }

      # Eni
      {
        port1 :
          name : "eni-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
        port2 :
          name : "eni-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }
      {
        port1 :
          name : "launchconfig-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name : "eni-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }
      {
        port1 :
          name : "launchconfig-sg"
          type : "ExpandedAsg"
        port2 :
          name : "eni-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }
      {
        port1 :
          name : "elb-sg-in"
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
        port2 :
          name : "eni-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }

      # LC
      {
        port1 :
          name : "launchconfig-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name : "launchconfig-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      }
      {
        port1 :
          name : "launchconfig-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name : "launchconfig-sg"
          type : "ExpandedAsg"
      }
      {
        port1 :
          name : "launchconfig-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name : "elb-sg-in"
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
      }

      # Elb
      {
        port1 :
          name : "launchconfig-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name : "elb-sg-in"
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
      }
      {
        port1 :
          name : "launchconfig-sg"
          type : "ExpandedAsg"
        port2 :
          name : "elb-sg-in"
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
      }
    ]
  }, {
    isConnectable : ( p1Comp, p2Comp )->
      tag = p1Comp.type + ">" + p2Comp.type
      if tag.indexOf( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance ) isnt -1 and tag.indexOf( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface ) isnt -1

        for attach in p1Comp.connectionTargets("EniAttachment")
          if attach is p2Comp
            return "The Network Interface is attached to the instance. No need to connect them by security group rule."

      true
  }

  SgRuleLine


