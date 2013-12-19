#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', "Design", 'constant', 'event'  ], ( PropertyModel, Design, constant, ide_event ) ->

    SgModel = PropertyModel.extend {

        init : ( uid ) ->

            if @isReadOnly
                @appInit uid
                return

            component = Design.instance().component( uid )

            rules = []
            for rule in component.connections("SgRuleSet")
                rules = rules.concat( rule.toPlainObjects( uid ) )

            members = _.map component.connections("SgAsso"), ( asso )->
                asso.getOtherTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup ).get("name")

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

                # If the SG is Elb SG, its rule is not editable
                @set "ruleEditable", false
            else if @isAppEdit
                # In AppEdit mode, if the SG has no aws resource associated :
                # Meaning it is a newly created SG. So the input should be editable
                inputReadOnly = component.get("appId")

            if inputReadOnly or component.get("isDefault")
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
            sgRuleSet.addRule( mySg.id, rule.direction, rule )

            # See if the rule is inserted
            if beforeCount < sgRuleSet.ruleCount( mySg.id )
                rules = []
                for rule in mySg.connections("SgRuleSet")
                    rules = rules.concat( rule.toPlainObjects( uid ) )
                @attributes.rules = rules
                @sortSGRule()
                return true
            else
                return false

        createSGRuleData : ()->
            sgList = _.map Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup ).allObjects(), ( sg )->
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
            currentRegion = MC.canvas_data.region
            currentSGComp = MC.canvas_data.component[sg_uid]
            currentSGID = currentSGComp.resource.GroupId
            currentAppSG = MC.data.resource_list[currentRegion][currentSGID]

            members = MC.aws.sg.getAllRefComp sg_uid

            rules = MC.aws.sg.getAllRule currentAppSG, true

            #get sg name
            sg_app_detail =
                uid         : sg_uid
                name        : currentSGComp.name
                groupName   : currentAppSG.groupName
                description : currentAppSG.groupDescription
                groupId     : currentAppSG.groupId
                ownerId     : currentAppSG.ownerId
                vpcId       : currentAppSG.vpcId
                members     : members
                rules       : rules

            @set sg_app_detail
            null

    }

    new SgModel()
