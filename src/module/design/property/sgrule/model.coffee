#############################
#  View Mode for design/property/sgrule
#############################

define [ '../base/model', "Design" ], ( PropertyModel, Design ) ->

    SGRuleModel = PropertyModel.extend {

        init : ( line_id ) ->
            if @isApp
                @getAppDispSGList line_id
                return

            connection = Design.instance().component( line_id )
            if not connection then return

            SgRuleSetModel = Design.modelClassForType( "SgRuleSet" )

            allRuleSets = SgRuleSetModel.getRelatedSgRuleSets( connection.port1Comp(), connection.port2Comp() )

            @set {
                uid    : line_id
                groups : SgRuleSetModel.getGroupedObjFromRuleSets( allRuleSets )
            }
            null
    }

    new SGRuleModel()
