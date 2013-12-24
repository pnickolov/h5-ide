####################################
#  Controller for design/property/sgrule module
####################################

define [ '../base/main',
         './model',
         './view',
         'component/sgrule/main'
], ( PropertyModule, model, view, sgrule_main ) ->

	view.on "EDIT_RULE", () ->
		sgrule_main.loadModule( model.get("uid") )

	SgRuleModule = PropertyModule.extend {

		handleTypes : [ "ElbAmiAsso", "SgRuleLine" ]

		initStack : ()->
			@model = model
			@model.isApp = false
			@view  = view
			null

		initApp : ()->
			@model = model
			@model.isApp = true
			@view  = view
			null

		initAppEdit : ()->
			@model = model
			@model.isApp = false
			@view  = view
			null
	}
	null
