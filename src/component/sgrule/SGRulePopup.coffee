####################################
#  pop-up for component/sgrule module
####################################

define [ 'constant', "Design", './SGRulePopupView', "backbone" ], ( constant, Design, View ) ->

  SGRulePopupModel = Backbone.Model.extend {

    initialize : ()->

      design = Design.instance()

      @set "isClassic", design.typeIsClassic()

      port1 = @get("port1")
      port2 = @get("port2")

      # Get sg of each port
      if @get( "isClassic" )
        if port1.type is constant.AWS_RESOURCE_TYPE.AWS_ELB
          port1 = port1.get("name")
        else if port2.type is constant.AWS_RESOURCE_TYPE.AWS_ELB
          port1 = port2.get("name")
          port2 = @get("port1")


      map = ( sg )->
        {
          uid   : sg.id
          color : sg.color
          name  : sg.get("name")
        }

      @set "relation", _.map port2.connectionTargets( "SgAsso" ), map

      if _.isString port1
        @set "owner", { name : port1, uid : @get("port1").id }
      else
        @set "owner", _.map port1.connectionTargets( "SgAsso" ), map


      @updateGroupList()

      null

    updateGroupList : ()->
      design = Design.instance()
      cnn = design.component( @get("uid") )

      # Get all the sgrules
      SgRuleSetModel = Design.modelClassForType( "SgRuleSet" )
      allRuleSets = SgRuleSetModel.getRelatedSgRuleSets @get("port1"), @get("port2")

      @set "groups", SgRuleSetModel.getGroupedObjFromRuleSets( allRuleSets )
      null

    addRule : ( data )->

      targetComp   = Design.instance().component( data.target )
      relationComp = Design.instance().component( data.relation )

      if targetComp.type is constant.AWS_RESOURCE_TYPE.AWS_ELB
        # We create a mock sg for ElbSg in Classic.
        SgModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )
        targetComp = SgModel.getClassicElbSg()

      SgRuleSetModel = Design.modelClassForType( "SgRuleSet" )
      sgRuleSet      = new SgRuleSetModel( targetComp, relationComp )

      count = if @get("isClassic") then 1 else 2

      if @get("isClassic")
        # Don't add sgrule to ElbSg in classic mode
        sgRuleSet.addRawRule( data.relation, "inbound", data )
      else
        sgRuleSet.addRule( data.target, data.direction, data )

      if data.direction is "biway"
        count *= 2

      @updateGroupList()
      count

    delRule : ( data )->
      sgRuleSet = Design.instance().component( data.ruleSetId )
      sgRuleSet.removeRuleByPlainObj( data )
      null
  }

  SGRulePopup = ( line_id, port2Comp )->
    if port2Comp
      port1Comp  = line_id
      line_id = ""
    else
      cnn = Design.instance().component( line_id )
      port1Comp = cnn.port1Comp()
      port2Comp = cnn.port2Comp()

    model = new SGRulePopupModel({ port1 : port1Comp, port2 : port2Comp, lineId : line_id })
    (new View({model:model})).render()

  SGRulePopup
