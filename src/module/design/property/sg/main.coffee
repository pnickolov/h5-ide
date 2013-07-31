####################################
#  Controller for design/property/sg module
####################################

define [ 'jquery',
		 'text!/module/design/property/sg/template.html',
		 'text!/module/design/property/sg/app_template.html',
		 'event'
], ( $, template, app_template, ide_event ) ->

	#
	current_view  = null
	current_model = null

	#add handlebars script
	template = '<script type="text/x-handlebars-template" id="property-sg-tmpl">' + template + '</script>'
	$( 'head' ).append template

	app_template = '<script type="text/x-handlebars-template" id="property-sg-app-tmpl">' + app_template + '</script>'
	$( 'head' ).append app_template

	#private
	loadModule = ( sg_uid, is_app_view, current_main ) ->

		#
		# MC.data.current_sub_main = current_main

		if !is_app_view
			require [ './module/design/property/sg/view', './module/design/property/sg/model' ], ( view, model ) ->

				#

				# if current_view view.delegateEvents view.events

				#
				current_view  = view
				current_model = model

				#view
				view.model    = model

				if sg_uid
					view.model.getSG sg_uid
				else
					view.model.addSG()

				#render
				view.render()

				#temp hack
				if view._events
					return

				view.on 'SET_SG_NAME', ( sg_uid, value ) ->
					model.setSGName sg_uid, value

				view.on 'REMOVE_SG_RULE', ( sg_uid, rule )->

					model.removeSGRule sg_uid, rule

				view.on 'SET_SG_RULE', ( sg_uid, rule ) ->

					model.setSGRule sg_uid, rule

				view.on 'SET_SG_DESC', ( sg_uid, value ) ->

					model.setSGDescription sg_uid, value

		else

			require [ './module/design/property/sg/view', './module/design/property/sg/model' ], ( view, model ) ->

				view.model = model

				if sg_uid
					model.getAppSG sg_uid

				#render
				view.render(is_app_view)

	unLoadModule = () ->

	#public
	loadModule   : loadModule
	unLoadModule : unLoadModule
