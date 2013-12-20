
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
  }

  Model = ComplexResModel.extend {

    type        : constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup
    newNameTmpl : "custom-sg-"
    color       : "#f26c4f"

    defaults :
      isDefault : false

    initialize : ()->
      @color = @generateColor()
      null

    isElbSg    : ()-> @get "isElbSg"
    setAsElbSg : ()-> @set "isElbSg", true

    createIpTarget : ( ipAddress )-> ipTarget = new SgIpTarget( ipAddress )


    ruleCount : ()->
      count = 0
      for ruleset in @connections( "SgRuleSet" )
        count += ruleset.ruleCount( @id )
      count

    connect : ( cn )->

      # Don't modify SgLine when Design is not ready for drawing
      if not Design.instance().shouldDraw() then return

      if cn.type is "SgAsso"
        @vlineAdd( cn.getOtherTarget( @ ) )

      else if cn.type is "SgRuleSet"

        # Only when this SG is the port1Comp(), we do update.
        # Otherwise, we might update twice when the SgRuleSet is created.
        if cn.port1Comp() is @
           # SgIpTarget has no visual line.
          if cn.port2Comp().type isnt "SgIpTarget"
            @vlineAddBatch( cn.port2Comp() )
      null

    disconnect : ( cn )->

      # Don't modify SgLine when Design is not ready for drawing
      if not Design.instance().shouldDraw() then return

      if cn.type is "SgAsso"
        @vlineRemove( cn.getOtherTarget( @ ) )

      else if cn.type is "SgRuleSet"

        if cn.port1Comp is @
          if cn.port2Comp().type isnt "SgIpTarget"
            @vlineRemoveBatch( cn.port2Comp() )
      null

    vlineAdd : ( resource )->
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

      # Do not add visual line for self reference rule
      if otherSg is @ then return

      groupRes = @connectionTargets( "SgAsso" )

      for otherRes in otherSg.connectionTargets( "SgAsso" )
        for myRes in groupRes
          if myRes isnt otherRes
            new SgLine( myRes, otherRes )

      null

    vlineRemove : ( resource, possibleAffectedRes )->

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
        if not connectableMap[ res.id ] and res isnt resource
            (new SgLine(resource, res)).remove()
      null

    vlineRemoveBatch : ( otherSg )->
      possibleAffectedRes = otherSg.connectionTargets( "SgAsso" )

      for resource in @connectionTargets( "SgAsso" )
        @vlineRemove( resource, possibleAffectedRes )
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
      if @get("isDefault") then return "#" + MC.canvas.SG_COLORS[0]

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

  }, {

    getDefaultSg : ()->
      _.find Model.allObjects(), ( obj )-> obj.get("isDefault")

    tryDrawLine : ( leftRes, rightRes )->
      rightMap = {}
      for sg in rightRes.connectionTargets("SgAsso")
        rightMap[ sg.id ] = true

      for sg in leftRes.connectionTargets("SgAsso")
        for connectedSg in sg.getVisualConnectedSg()
          if rightMap[ connectedSg.id ]
            new SgLine( leftRes, rightRes )
            return

      null


    updateSgLines : ()->
      ### env:dev ###
      if this isnt Design
        console.error( "Possible misuse of updateSgLines detected!" )
      ### env:dev:end ###

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

        name  : data.name
        id    : data.uid
        appId : data.resource.GroupId

        isDefault   : data.name is "DefaultSG"
        description : data.resource.GroupDescription

      })

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

  Design.on "deserialized", Model.updateSgLines

  Model
