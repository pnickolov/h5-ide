####################################
#  Controller for design/property/sgrule module
####################################

define [ '../base/main',
         './model',
         './view',
         'component/sgrule/main'
], ( PropertyModule, model, view, sgrule_main ) ->


	SgRuleModule = PropertyModule.extend {

		handleTypes : /.+-sg\>/

		setupStack : ()->
			view.on "EDIT_RULE", ( line_id ) ->
				sgrule_main.loadModule( line_id )
			null

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
	}
	null
