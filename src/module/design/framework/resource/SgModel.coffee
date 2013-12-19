
define [ "../ComplexResModel", "../ResourceModel", "../connection/SgRuleSet", "../connection/SgLine", "constant" ], ( ComplexResModel, ResourceModel, SgRuleSet, SgLine, constant )->

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
      if cn.type is "SgAsso"
        possibleAffectedResources = []

        for ruleset in @getVisualRuleSet()
          for otherAsso in ruleset.getOtherTarget( @ ).connections( "SgAsso" )
            possibleAffectedResources.push otherAsso.getOtherTarget( constan.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )

        @vlineRemove( cn.getOtherTarget( @ ), possibleAffectedResources )

      else if cn.type is "SgRuleSet"

        if cn.port1Comp is @
          if cn.port2Comp().type isnt "SgIpTarget"
            @vlineRemoveBatch( cn.port2Comp() )
      null

    vlineAdd : ( resource )->
      connectedResMap = {}
      # Get all the resources that will connect to SG.
      for sg in @getVisualConnectedSg()

        for asso in sg.connections( "SgAsso" )

          res = asso.getOtherTarget( sg )

          # The res is already connected
          if connectedResMap[ res.id ] then continue

          # Avoid connecting to the resource's self
          if resource isnt res then new SgLine( resource, res )
          connectedResMap[ res.id ] = true
      null

    vlineAddBatch : ( otherSg )->

      # Do not add visual line for self reference rule
      if otherSg is @ then return

      groupRes = []
      for asso in @connections( "SgAsso" )
        groupRes.push asso.getOtherTarget( @ )

      for asso in otherSg.connections( "SgAsso" )
        otherRes = asso.getOtherTarget( otherSg )

        for myRes in groupRes
          if myRes isnt otherRes
            new SgLine( myRes, otherRes )

      null

    vlineRemove : ( resource, possibleAffectedResources )->
      connectableMap = {}

      # Find out what resource can connect to
      for asso in resource.connections( "SgAsso" )

        sg = asso.getOtherTarget( resource )
        for ruleset in sg.getVisualRuleSet()

          for otherAsso in ruleset.getOtherTarget( sg ).connections( "SgAsso" )

            connectableMap[ otherAsso.getOtherTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup ).id ] = true

      # Try remove all the resources connectable to this SG
      for res in possibleAffectedResources
        if not connectableMap[ res.id ]
            (new SgLine(resource, res)).remove()
      null

    vlineRemoveBatch : ( otherSg )->
      possibleAffectedResources = []

      for asso in otherSg.connections( "SgAsso" )
        possibleAffectedResources.push( asso.getOtherTarget( otherSg ) )

      for asso in @connections( "SgAsso" )
        @vlineRemove( asso.getOtherTarget(@), possibleAffectedResources )
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

  Model
