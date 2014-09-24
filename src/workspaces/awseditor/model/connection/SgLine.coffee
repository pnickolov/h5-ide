
define [ "constant", "ConnectionModel", "ResourceModel", "i18n!/nls/lang.js" ], ( constant, ConnectionModel, ResourceModel, lang )->

  # SgRuleLine is used to draw lines in canvas
  SgRuleLine = ConnectionModel.extend {

    constructor : ( p1Comp, p2Comp, attr, option ) ->

      console.assert( p1Comp isnt p2Comp, "Sgline should connect to different resources." )

      # Override the constructor to determine if the line should be created.
      # Using the `@setDestroyAfterInit()` has its limilation

      if not @assignCompsToPorts( p1Comp, p2Comp ) or not @isValid()
        return

      ConnectionModel.call this, p1Comp, p2Comp, attr, option

    # Return true if the line is valid and should be shown.
    # Otherwise return false.
    isValid : ()->
      p1Comp = @port1Comp()
      p2Comp = @port2Comp()

      TYPE   = constant.RESTYPE

      # There will never be sgline between two Elb.
      if p1Comp.type is p2Comp.type and p1Comp.type is TYPE.AWS_ELB
        return false

      # Sgline only exist when eni is not attached to the ami
      ami = @getTarget TYPE.INSTANCE
      eni = @getTarget TYPE.ENI
      if eni
        attachs = eni.connectionTargets( "EniAttachment" )
        # Unattached Eni doesn't have SgLine.
        if attachs.length == 0 then return false
        if attachs.indexOf( ami ) >= 0 then return false

      # Hide sglist between lc and expandedasg
      expandAsg = @getTarget "ExpandedAsg"
      lc        = @getTarget TYPE.LC
      if expandAsg and lc and expandAsg.get("originalAsg").getLc() is lc
        return false

      # Rules for checking sgline of elb.
      elb = @getTarget TYPE.ELB
      if elb
        # If elb is internet-facing, don't show line.
        if not elb.get("internal") then return false

        # If the elb's sgline doesn't represent an in rule to the elb. don't show line.
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

        if not hasInRule then return false

      true


    validate : ()->
      if not @isValid() then @remove( { reason : "Validation Failed" } )
      return


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
      name : "Security Group Rule"

    portDefs : [

      # Instance
      {
        port1 :
          name : "instance-sg"
          type : constant.RESTYPE.INSTANCE
        port2 :
          name : "instance-sg"
          type : constant.RESTYPE.INSTANCE
      }
      {
        port1 :
          name : "instance-sg"
          type : constant.RESTYPE.INSTANCE
        port2 :
          name : "eni-sg"
          type : constant.RESTYPE.ENI
      }
      {
        port1 :
          name : "instance-sg"
          type : constant.RESTYPE.INSTANCE
        port2 :
          name : "launchconfig-sg"
          type : constant.RESTYPE.LC
      }
      {
        port1 :
          name : "instance-sg"
          type : constant.RESTYPE.INSTANCE
        port2 :
          name : "launchconfig-sg"
          type : "ExpandedAsg"
      }
      {
        port1 :
          name : "instance-sg"
          type : constant.RESTYPE.INSTANCE
        port2 :
          name : "elb-sg-in"
          type : constant.RESTYPE.ELB
      }
      {
        port1 :
          name : "instance-sg"
          type : constant.RESTYPE.INSTANCE
        port2 :
          name : "db-sg"
          type : constant.RESTYPE.DBINSTANCE
      }

      # Eni
      {
        port1 :
          name : "eni-sg"
          type : constant.RESTYPE.ENI
        port2 :
          name : "eni-sg"
          type : constant.RESTYPE.ENI
      }
      {
        port1 :
          name : "launchconfig-sg"
          type : constant.RESTYPE.LC
        port2 :
          name : "eni-sg"
          type : constant.RESTYPE.ENI
      }
      {
        port1 :
          name : "launchconfig-sg"
          type : "ExpandedAsg"
        port2 :
          name : "eni-sg"
          type : constant.RESTYPE.ENI
      }
      {
        port1 :
          name : "elb-sg-in"
          type : constant.RESTYPE.ELB
        port2 :
          name : "eni-sg"
          type : constant.RESTYPE.ENI
      }

      # LC
      {
        port1 :
          name : "launchconfig-sg"
          type : constant.RESTYPE.LC
        port2 :
          name : "launchconfig-sg"
          type : constant.RESTYPE.LC
      }
      {
        port1 :
          name : "launchconfig-sg"
          type : constant.RESTYPE.LC
        port2 :
          name : "launchconfig-sg"
          type : "ExpandedAsg"
      }
      {
        port1 :
          name : "launchconfig-sg"
          type : constant.RESTYPE.LC
        port2 :
          name : "elb-sg-in"
          type : constant.RESTYPE.ELB
      }

      # Elb
      {
        port1 :
          name : "launchconfig-sg"
          type : constant.RESTYPE.LC
        port2 :
          name : "elb-sg-in"
          type : constant.RESTYPE.ELB
      }
      {
        port1 :
          name : "launchconfig-sg"
          type : "ExpandedAsg"
        port2 :
          name : "elb-sg-in"
          type : constant.RESTYPE.ELB
      }

      # DBInstance
      {
        port1 :
          name : "db-sg"
          type : constant.RESTYPE.DBINSTANCE
        port2 :
          name : "db-sg"
          type : constant.RESTYPE.DBINSTANCE
      }
      {
        port1 :
          name : "db-sg"
          type : constant.RESTYPE.DBINSTANCE
        port2 :
          name : "eni-sg"
          type : constant.RESTYPE.ENI
      }
      {
        port1 :
          name : "db-sg"
          type : constant.RESTYPE.DBINSTANCE
        port2 :
          name : "launchconfig-sg"
          type : constant.RESTYPE.LC
      }
      {
        port1 :
          name : "db-sg"
          type : constant.RESTYPE.DBINSTANCE
        port2 :
          name : "launchconfig-sg"
          type : "ExpandedAsg"
      }
      {
        port1 :
          name : "db-sg"
          type : constant.RESTYPE.DBINSTANCE
        port2 :
          name : "instance-sg"
          type : constant.RESTYPE.INSTANCE
      }
    ]
  }, {
    isConnectable : ( p1Comp, p2Comp )->
      tag = p1Comp.type + ">" + p2Comp.type
      if tag.indexOf( constant.RESTYPE.INSTANCE ) isnt -1 and tag.indexOf( constant.RESTYPE.ENI ) isnt -1

        for attach in p1Comp.connectionTargets("EniAttachment")
          if attach is p2Comp
            return lang.CANVAS.NETWORK_INTERFACE_ATTACHED_INTERFACE_NO_NEED_FOR_SG_RULE

      true
  }

  SgRuleLine


