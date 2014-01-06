
define [ "constant", "../ConnectionModel", "../ResourceModel", "component/sgrule/SGRulePopup" ], ( constant, ConnectionModel, ResourceModel, SGRulePopup )->

  # SgRuleLine is used to draw lines in canvas
  SgRuleLine = ConnectionModel.extend {

    initialize : ( attributes, option )->
      console.assert( @port1Comp() isnt @port2Comp(), "Sgline should connect to different resources." )

      # If Eni is attached to Ami, then hide sg line
      ami = @getTarget constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      eni = @getTarget constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      if ami and eni
        for e in ami.connectionTargets( "EniAttachment" )
          if e is eni
            @setDestroyAfterInit()
            return


      # If the line is created by the user, we should a popup dialog to let
      # user add sgrule. And then immediately remove the sgline
      if option and option.createByUser
        new SGRulePopup( this.id )
        @setDestroyAfterInit()
        return


      # Only show sg line for inbound rules of elb
      # If the target is elb and the elb is internet-facing, don't show sgline
      elb = @getTarget constant.AWS_RESOURCE_TYPE.AWS_ELB
      if elb
        if not elb.get("internal")
          @setDestroyAfterInit()
        else
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
            if hasInRule
              break

          if not hasInRule
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
      if reason then return

      SgRuleSetModel = Design.modelClassForType( "SgRuleSet" )
      for rs in SgRuleSetModel.getRelatedSgRuleSets( @port1Comp(), @port2Comp() )
        rs.remove()
      null



    # This method is used by Asg to remove its expanded asg's sgline.
    silentRemove : ()->
      CanvasManager.remove( document.getElementById( @id ) )
      ResourceModel.remove.apply( this, arguments )
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
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      }
      {
        port1 :
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name      : "eni-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }
      {
        port1 :
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      }
      {
        port1 :
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : "ExpandedAsg"
      }
      {
        port1 :
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name      : "elb-sg-in"
          type      : constant.AWS_RESOURCE_TYPE.AWS_ELB
      }

      # Eni
      {
        port1 :
          name      : "eni-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
        port2 :
          name      : "eni-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }
      {
        port1 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name      : "eni-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }
      {
        port1 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : "ExpandedAsg"
        port2 :
          name      : "eni-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }
      {
        port1 :
          name      : "elb-sg-in"
          type      : constant.AWS_RESOURCE_TYPE.AWS_ELB
        port2 :
          name      : "eni-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }

      # LC
      {
        port1 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      }
      {
        port1 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : "ExpandedAsg"
      }
      {
        port1 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name      : "elb-sg-in"
          type      : constant.AWS_RESOURCE_TYPE.AWS_ELB
      }

      # Elb
      {
        port1 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name      : "elb-sg-in"
          type      : constant.AWS_RESOURCE_TYPE.AWS_ELB
      }
      {
        port1 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : "ExpandedAsg"
        port2 :
          name      : "elb-sg-in"
          type      : constant.AWS_RESOURCE_TYPE.AWS_ELB
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


