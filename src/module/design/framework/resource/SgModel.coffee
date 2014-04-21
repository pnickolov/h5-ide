
define [ "../ComplexResModel", "../ResourceModel", "../connection/SgRuleSet", "../connection/SgLine", "Design", "constant" ], ( ComplexResModel, ResourceModel, SgRuleSet, SgLine, Design, constant )->

  SgTargetModel = ComplexResModel.extend {
    type : "SgIpTarget"

    constructor : ( ip )->
      cache = Design.instance().classCacheForCid( @classId )
      for ipTarget in cache
        if ipTarget.attributes.name is ip
          return ipTarget

      cache.push this

      Backbone.Model.call this, {
        id   : MC.guid()
        name : ip
      }
      this

    isClassicElbSg : ()-> @attributes.name is "amazon-elb/amazon-elb-sg"
    isVisual       : ()-> false
  }

  Model = ComplexResModel.extend {

    type        : constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup
    newNameTmpl : "custom-sg-"
    color       : "#f26c4f"

    defaults :
      description : "Custom Security Group"
      groupName   : ""

    initialize : ( attributes, option )->
      @color = @generateColor()

      if not (option and option.isDeserialize)
        # Automatically add an outbound rule to 0.0.0.0/0
        if @isElbSg()
          direction = SgRuleSet.DIRECTION.IN
          attr =
            fromPort : "22"
            toPort   : ""
            protocol : "tcp"
        else
          direction = SgRuleSet.DIRECTION.OUT
          attr =
            fromPort : "0"
            toPort   : "65535"
            protocol : "-1"

        (new SgRuleSet( this, @createIpTarget("0.0.0.0/0") )).addRawRule( this.id, direction, attr )
      null

    isElbSg    : ()-> @get "isElbSg"
    setAsElbSg : ()-> @set "isElbSg", true

    isDefault : ()-> @attributes.name is "DefaultSG"
    isVisual  : ()-> false

    createIpTarget : ( ipAddress )-> new SgTargetModel( ipAddress )

    getNewName : ()->
      myKinds = Design.modelClassForType( @type ).allObjects()
      ResourceModel.prototype.getNewName.call( this, myKinds.length - 1 )

    ruleCount : ()->
      count = 0
      for ruleset in @connections( "SgRuleSet" )
        count += ruleset.ruleCount( @id )
      count

    getMemberList : ()->
      # Sg member does not include any ExpandedAsg
      _.filter @connectionTargets("SgAsso"), ( tgt )-> tgt.type isnt "ExpandedAsg"

    connect : ( cn )->
      if cn.type is "SgAsso"
        @vlineAdd( cn.getOtherTarget( @ ) )

      # Unlike disconnecting from SgRuleSet,
      # at the time when a SgRuleSet is created, there is no rule inside
      # the SgRuleSet. Which means we cannot determine if we need to
      # add SgRuleLine at this time.
      # So we let SgRuleSet to call SgModel.vlineAddBatch() when first rule is inserted.
      null

    disconnect : ( cn )->
      if cn.type is "SgAsso"
        @vlineRemove( cn.getOtherTarget( @ ), undefined, cn )

      else if cn.type is "SgRuleSet"

        if cn.port1Comp() is @
          if cn.port2Comp().type isnt "SgIpTarget"
            @vlineRemoveBatch( cn.port2Comp(), cn )
      null

    vlineAdd : ( resource )->
      # Don't modify SgLine when Design is not ready for drawing
      if not Design.instance().shouldDraw() then return

      connectedResMap = {}
      # Get all the resources that will connect to SG.
      for sg in @getVisualConnectedSg()

        for res in sg.connectionTargets( "SgAsso" )

          # The res is already connected
          if connectedResMap[ res.id ] then continue

          # Avoid connecting to the resource's self
          if resource isnt res then new SgLine( resource, res )
          connectedResMap[ res.id ] = true
      null

    vlineAddBatch : ( otherSg )->

      if not Design.instance().shouldDraw() then return

      # Do not add visual line for self reference rule
      if otherSg is @ then return

      groupRes = @connectionTargets( "SgAsso" )

      for otherRes in otherSg.connectionTargets( "SgAsso" )
        for myRes in groupRes
          if myRes isnt otherRes
            new SgLine( myRes, otherRes )

      null

    vlineRemove : ( resource, possibleAffectedRes, reason )->

      if not Design.instance().shouldDraw() then return

      # Get a list of target resources that might need to update.
      if not possibleAffectedRes
        possibleAffectedRes = []
        for sg in @getVisualConnectedSg()
          possibleAffectedRes = possibleAffectedRes.concat( sg.connectionTargets("SgAsso") )

      connectableMap = {}

      # Find out what resource can connect to
      for resourceSg in resource.connectionTargets( "SgAsso" )

        for sg in resourceSg.getVisualConnectedSg()

          for sgTarget in sg.connectionTargets( "SgAsso" )

            connectableMap[ sgTarget.id ] = true

      # Try remove all the resources connectable to this SG
      for res in possibleAffectedRes
        if res is resource then continue
        cn = SgLine.findExisting( resource, res )

        if cn # There's a line between two resources.
          if not connectableMap[ res.id ]
            cn.remove( reason )
          else
            cn.validate()
      null

    vlineRemoveBatch : ( otherSg, reason )->
      if not Design.instance().shouldDraw() then return

      possibleAffectedRes = otherSg.connectionTargets( "SgAsso" )

      for resource in @connectionTargets( "SgAsso" )
        @vlineRemove( resource, possibleAffectedRes, reason )
      null

    # Get the collections of SG, which will have visual lines to this SG
    getVisualConnectedSg : ()->
      cnns = []
      for cnn in @get("__connections")

        if cnn.type is "SgRuleSet" and cnn.port1Comp() isnt cnn.port2Comp() and not cnn.getTarget( "SgIpTarget" )
          cnns.push cnn.getOtherTarget( @ )

      cnns

    generateColor : ()->
      # The first color is always for DefaultSG
      if @isDefault() then return "#" + MC.canvas.SG_COLORS[0]

      usedColor = {}
      for sg in Model.allObjects()
        usedColor[ sg.color ] = true

      i = 1
      while i < MC.canvas.SG_COLORS.length
        c = "#" + MC.canvas.SG_COLORS[i]
        if not usedColor[ c ]
          color = c
          break
        ++i

      if not color
        color = Math.floor(Math.random() * 0xFFFFFF).toString(16)
        while color.length < 6
          color = '0' + color
        color = "#" + color

      color

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          Default          : @isDefault()
          GroupId          : @get("appId")
          GroupName        : @get("groupName") or @get("name")
          GroupDescription : @get("description")
          VpcId            : @getVpcRef()
          IpPermissions       : []
          IpPermissionsEgress : []

      { component : component }
  }, {

    getClassicElbSg : ()-> new SgTargetModel( "amazon-elb/amazon-elb-sg" )

    getDefaultSg : ()->
      _.find Model.allObjects(), ( obj )-> obj.isDefault()

    # This method will try to draw a line if the leftRes connects to rightRes
    # If rightRes is undefined, it will try to redraw sgLine for leftRes
    tryDrawLine : ( leftRes, rightRes )->

      if rightRes
        rightMap = {}
        for sg in rightRes.connectionTargets("SgAsso")
          rightMap[ sg.id ] = true

        for sg in leftRes.connectionTargets("SgAsso")
          for connectedSg in sg.getVisualConnectedSg()
            if rightMap[ connectedSg.id ]
              new SgLine( leftRes, rightRes )
              return
      else
        rightResArr = []
        for sg in leftRes.connectionTargets("SgAsso")

          for otherSg in sg.getVisualConnectedSg()

            rightResArr = _.union rightResArr, otherSg.connectionTargets("SgAsso")

        for rightRes in rightResArr
          if leftRes isnt rightRes
            new SgLine( leftRes, rightRes )

      null

    updateSgLines : ()->
      console.assert( this is Design, "Possible misuse of updateSgLines detected!" )

      connectableMap = {}
      for ruleset in SgRuleSet.allObjects()
        sg1 = ruleset.port1Comp()
        sg2 = ruleset.port2Comp()

        # Self-reference and IpTarget Ruleset is not visual
        if sg1 is sg2 or sg1.type is "SgIpTarget" or sg2.type is "SgIpTarget" then continue

        leftPortRes = sg1.connectionTargets( "SgAsso" )

        for resource in sg2.connectionTargets( "SgAsso" )
          for leftRes in leftPortRes
            # Avoid created line if two port is the same
            if leftRes.id is resource.id then continue
            if leftRes.id < resource.id
              key = leftRes.id + "|" + resource.id
            else
              key = resource.id + "|" + leftRes.id

            a = connectableMap[ key ] || []
            a[0] = leftRes
            a[1] = resource
            connectableMap[ key ] = a


      for idKey, ress of connectableMap
        # Create a SgLine between the object, and avoid duplicate check in ConnectionModel
        new SgLine( ress[0], ress[1], undefined, { detectDuplicate : false } )
      null

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

    deserialize : ( data, layout_data, resolve )->

      group = new Model({
        name      : data.name
        id        : data.uid
        appId     : data.resource.GroupId
        groupName : data.resource.GroupName

        description : data.resource.GroupDescription
      }, { isDeserialize : true} )

      rules = []
      if data.resource.IpPermissions
        for rule in data.resource.IpPermissions
          rules.push { rule : rule }
      if data.resource.IpPermissionsEgress
        for rule in data.resource.IpPermissionsEgress
          rules.push { rule : rule, out : true }

      for ruleObj in rules
        rule = ruleObj.rule

        if rule.IpRanges[0] is "@"
          ruleTarget = resolve( MC.extractID(rule.IpRanges) )
        else
          ruleTarget = new SgTargetModel( rule.IpRanges )

        if not ruleTarget then continue

        attr =
          fromPort : rule.FromPort
          toPort   : rule.ToPort
          protocol : rule.IpProtocol


        # The rule might already exist, so we call addDirection here
        # to try to upgrade the direction.
        dir = if ruleObj.out then SgRuleSet.DIRECTION.OUT else SgRuleSet.DIRECTION.IN
        (new SgRuleSet( group, ruleTarget )).addRawRule( group.id, dir, attr )
      null
  }

  Design.on Design.EVENT.Deserialized, Model.updateSgLines

  Model
