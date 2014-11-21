####################################
#  pop-up for component/sgrule module
####################################

define [ 'constant', "Design", 'component/awscomps/SGRulePopupView', "backbone" ], ( constant, Design, View ) ->

  SGRulePopupModel = Backbone.Model.extend {

    initialize : ()->

      design = Design.instance()

      port1 = @get("port1")
      port2 = @get("port2")

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

      SgRuleSetModel = Design.modelClassForType( "SgRuleSet" )
      sgRuleSet      = new SgRuleSetModel( targetComp, relationComp )

      count = 2

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
