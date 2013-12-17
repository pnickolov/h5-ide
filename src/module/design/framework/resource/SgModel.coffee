
define [ "../ComplexResModel", "../ResourceModel", "../connection/SgRule", "constant" ], ( ComplexResModel, ResourceModel, SgRule, constant )->

  SgTargetModel = ComplexResModel.extend {
    type : "SgIpTarget"

    initialize : ()->
      # I don't want SgTargetModel to appear in global Design cache.
      # So we call remove() right after it's created.
      @remove()
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

    isElbSg : ()->
      false


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
        _.each data.resource.IpPermissions, ( rule )->
          rules.push { rule : rule }
          null
      if data.resource.IpPermissionsEgress
        _.each data.resource.IpPermissionsEgress, ( rule )->
          rules.push { rule : rule, out : true }
          null

      for ruleObj in rules
        rule = ruleObj.rule

        if rule.IpRanges[0] is "@"
          ruleTarget = resolve( MC.extractID(rule.IpRanges) )
        else
          ruleTarget = new SgTargetModel( { name : rule.IpRanges } )

        attr =
          fromPort : rule.FromPort
          toPort   : rule.ToPort
          protocol : rule.IpProtocol

        rule = new SgRule( group, ruleTarget, attr )
        # The rule might already exist, so we call addDirection here
        # to try to upgrade the direction.
        if ruleObj.out
          rule.setOut( group, true )
        else
          rule.setIn( group, true )

      null
  }

  Model
