#############################
#  View Mode for component/sgrule
#############################

define [ 'constant', "Design", 'backbone' ], ( constant, Design ) ->

  SGRulePopupModel = Backbone.Model.extend {


    initialize : ()->

      design = Design.instance()
      cnn = design.component( @get("uid") )

      @set "isClassic", design.typeIsClassic() or design.typeIsDefaultVpc()

      # Get sg of each port
      if @get( "isClassic" )
        port1 = cnn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_ELB )
        if port1
          port1 = port1.get("name")
          port2 = cnn.getOtherTarget( constant.AWS_RESOURCE_TYPE.AWS_ELB )
        else
          port1 = cnn.port1Comp()
          port2 = cnn.port2Comp()

      else
        port1 = cnn.port1Comp()
        port2 = cnn.port2Comp()

      if _.isString port1
        @set "owner", { name : port1 }
      else
        map = ( sg )->
          {
            uid   : sg.id
            color : sg.color
            name  : sg.get("name")
          }

        @set "owner",    _.map port1.connectionTargets( "SgAsso" ), map
        @set "relation", _.map port2.connectionTargets( "SgAsso" ), map


      @updateGroupList()

      null

    updateGroupList : ()->
      design = Design.instance()
      cnn = design.component( @get("uid") )

      # Get all the sgrules
      SgRuleSetModel = Design.modelClassForType( "SgRuleSet" )
      allRuleSets = SgRuleSetModel.getRelatedSgRuleSets cnn.port1Comp(), cnn.port2Comp()

      @set "groups", SgRuleSetModel.getGroupedObjFromRuleSets( allRuleSets )
      null

    addRule : ( data )->

      @updateGroupList()
      null

    delRule : ( data )->
      sgRuleSet = Design.instance().component( data.ruleSetId )
      sgRuleSet.removeRuleByPlainObj( rule )
      null

    deleteLine : ()->

  }

  return SGRulePopupModel
