#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', "Design", 'constant', 'event'  ], ( PropertyModel, Design, constant, ide_event ) ->

    SgModel = PropertyModel.extend {

        init : ( uid ) ->
            @component = component = Design.instance().component( uid )

            if @isReadOnly
                @appInit uid
                return

            rules = []
            for rule in component.connections("SgRuleSet")
                rules = rules.concat( rule.toPlainObjects( uid, true ) )

            members = _.map component.getMemberList(), ( tgt )-> tgt.get("name")

            @set {
                uid          : uid
                name         : component.get("name")
                description  : component.get("description")
                members      : members
                rules        : rules
                color        : component.color
                ruleEditable : true
            }

            @sortSGRule()

            # Set Editable
            if component.isElbSg()
                inputReadOnly = true

            else if @isAppEdit
                # In AppEdit mode, if the SG has no aws resource associated :
                # Meaning it is a newly created SG. So the input should be editable
                inputReadOnly = component.get("appId")

            if inputReadOnly or component.isDefault()
                @set 'nameReadOnly', true
            if inputReadOnly
                @set 'descReadOnly', true


            null

        setDescription : ( value ) ->
            Design.instance().component( @get("uid") ).set( "description", value )
            null

        sortSGRule : ( key )->
            @attributes.rules = _.sortBy @attributes.rules, ( key or "direction" )
            null

        addRule : ( rule )->
            uid  = @get("uid")
            mySg = Design.instance().component( uid )

            # Get Target
            if rule.relation[0] is "@"
                target = Design.instance().component( rule.relation.substr(1) )
            else
                # The source/destination is Ip
                target = mySg.createIpTarget( rule.relation )

            # Get the SgRuleSet
            SgRuleSetModel = Design.modelClassForType( "SgRuleSet" )
            sgRuleSet = new SgRuleSetModel( mySg, target )

            # Insert Rule
            beforeCount = sgRuleSet.ruleCount( mySg.id )
            sgRuleSet.addRawRule( mySg.id, rule.direction, rule )

            # See if the rule is inserted
            if beforeCount < sgRuleSet.ruleCount( mySg.id )
                rules = []
                for rule in mySg.connections("SgRuleSet")
                    rules = rules.concat( rule.toPlainObjects( uid, true ) )
                @attributes.rules = rules
                @sortSGRule()
                return true
            else
                return false

        createSGRuleData : ()->
            sgList = _.map Design.modelClassForType( constant.RESTYPE.SG ).allObjects(), ( sg )->
                {
                    id    : sg.id
                    color : sg.color
                    name  : sg.get("name")
                }

            {
                isClassic : Design.instance().typeIsClassic()
                sgList    : sgList
            }

        removeRule : ( rule )->
            sgRuleSet = Design.instance().component( rule.ruleSetId )
            sgRuleSet.removeRuleByPlainObj( rule )
            null

        appInit : ( sg_uid ) ->

            # get sg obj
            currentRegion = Design.instance().region()
            currentSGID = @component.get 'appId'
            currentAppSG = MC.data.resource_list[ currentRegion ][ currentSGID ]

            rules = []
            for rule in @component.connections("SgRuleSet")
                rules = rules.concat( rule.toPlainObjects( sg_uid ) )

            members = _.map @component.connectionTargets("SgAsso"), ( sgTarget )->
                sgTarget.get('name')

            #get sg name
            sg_app_detail =
                uid         : sg_uid
                name        : @component.get 'name'
                color       : @component.color
                groupName   : currentAppSG.groupName
                description : currentAppSG.groupDescription
                groupId     : currentAppSG.groupId
                ownerId     : currentAppSG.ownerId
                vpcId       : currentAppSG.vpcId
                members     : members
                rules       : rules

            @set sg_app_detail

            @sortSGRule()
            null

    }

    new SgModel()
