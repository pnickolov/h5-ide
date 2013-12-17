#############################
#  View Mode for design/property/instance
#############################

define [ "Design", "constant", 'lib/forge/app' ], ( Design, constant, forge_app ) ->

	SGListModel = Backbone.Model.extend {

		getSGInfoList : ->

			design       = Design.instance()
			parent_model = @parent_model

			readonly = false
			if design.modeIsApp()
				readonly = true
			else if design.modeIsAppEdit()
				if parent_model.isSGListReadOnly
					readonly = parent_model.isSGListReadOnly()


			isELBParent   = parent_model.get 'is_elb'
			isStackParent = parent_model.get 'is_stack'
			resource      = design.component( parent_model.get("uid") )
			resource_id   = if resource then resource.id else ""

			sg_list  = []
			allRules = []

			enabledSGCount = 0
			enabledSG = {}

			## ## ## Get All SG
			for sg in Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup ).allObjects()
				# Ignore ElbSG if the property panel is not stack/elb
				if sg.isElbSg() and not ( isELBParent or isStackParent )
					continue

				needShow = isStackParent or ( not readonly ) or sgChecked
				if not needShow
					continue

				if sg.isElbSg() or sg.get("isDefault") or readonly or isStackParent or resource.get("appId")
					deletable = false
				else
					deletable = true

				# SgAsso is a connection to represent SG <=> Resource
				assos = sg.connections( "SgAsso" )
				# SgRule is a connection to represent SG <=> SG
				rules = sg.connections( "SgRule" )

				# See what SG is used by this resource
				for asso in assos
					if asso.connectsTo( resource_id )
						++enabledSGCount
						enabledSG[ sg.id ] = true
						allRules = allRules.concat( rules )
						break

				sg_list.push {
					uid         : sg.id
					color       : sg.color
					name        : sg.get("name")
					desc        : sg.get("description")
					ruleCount   : rules.length
					memberCount : assos.length
					hideCheck   : readonly or isStackParent
					deletable   : deletable
					used        : enabledSG[ sg.id ]
				}


			## ## ## Get All Rules
			sgRuleAry = []

			# Only get plain rules, that its destination is our sg
			filter = ( ruleDestination ) -> enabledSG[ ruleDestination.id ]

			for rule in allRules
				sgRuleAry = sgRuleAry.concat( rule.toPlainObjects( filter ) )

			# Remove duplicate rules
			ruleMap = {}
			rules   = []
			for rule in sgRuleAry
				ruleString = rule.direction + rule.target + rule.protocol + rule.port
				if ruleMap[ ruleString ]
					continue
				ruleMap[ ruleString ] = true
				rules.push rule

			# Set
			@set {
				is_stack_sg  : isStackParent
				only_one_sg  : enabledSGCount is 1
				sg_list      : sg_list
				sg_length    : if isStackParent then sg_list.length else enabledSGCount
				readonly     : readonly
				sg_rule_list : rules
			}

			@sortSGList()
			@sortSGRule()
			null

		sortSGList : ()->
			@attributes.sg_list = @attributes.sg_list.sort ( a_sg, b_sg )->
				if a_sg.name is "DefaultSG" then return -1
				if b_sg.name is "DefaultSG" then return 1
				if a_sg.name <  b_sg.name   then return -1
				if a_sg.name == b_sg.name   then return 0
				if a_sg.name >  b_sg.name   then return 1


		sortSGRule : ( key )->
			sgRuleList = _.sortBy @attributes.sg_rule_list, ( key or "direction" )
			@set "sg_rule_list", sgRuleList
			null

		assignSG : ( sgUID, sgChecked ) ->

			SgAsso = Design.modelClassForType( "SgAsso" )
			design = Design.instance()

			uid = @parent_model.get("uid")

			console.assert( uid, "Resource not found when assigning SG" )

			# If an old SgAsso is created, new will return that old SgAsso
			asso = new SgAsso( design.component( uid ), design.component( sgUID ) )

			if sgChecked is false
				asso.remove()
			null

		deleteSG : (sgUID) ->
			Design.instance().component( sgUID ).remove()
			null

		createNewSG : ()->
			SgModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )
			model = new SgModel()
			model.id

	}

	new SGListModel()
