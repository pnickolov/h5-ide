####################################
#  Controller for design/property/sgrule module
####################################

define [ 'jquery',
		 'text!/module/design/property/sgrule/template.html',
		 'text!/module/design/property/sgrule/app_template.html',
		 'event'
], ( $, template, app_template, ide_event ) ->

	#
	current_view  = null
	current_model = null

	#add handlebars script
	template = '<script type="text/x-handlebars-template" id="property-sgrule-tmpl">' + template + '</script>'
	app_template = '<script type="text/x-handlebars-template" id="property-sgrule-app-tmpl">' + app_template + '</script>'

	#load remote html template
	$( 'head' ).append( template )
	$( 'head' ).append( app_template )

	#private
	loadModule = ( uid, type, current_main, tab_type ) ->

		#
		MC.data.current_sub_main = current_main

		#set view_type
		if tab_type is 'OPEN_APP' then view_type = 'app_view' else view_type = 'view'

		#
		require [ './module/design/property/sgrule/model', './module/design/property/sgrule/' + view_type, './component/sgrule/main' ], ( model, view, sgrule_main ) ->

			#
			if current_view then view.delegateEvents view.events

			#
			current_view  = view
			current_model = model

			#view
			view.model = model
			view.setAppView = if tab_type is 'OPEN_APP' then true else false

			model.setLineId uid

			model.getDispSGList uid
			#render
			view.render()
			ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, "Security Group Rule"

			view.on "EDIT_RULE", ( line_id ) ->
				# TODO : Show SG Rule Popup
				sgrule_main.loadModule( line_id )

	loadAppModule = (line_uid) ->

		require ['./module/design/property/sgrule/model', './module/design/property/sgrule/app_view'], (model, view) ->

			model.getAppDispSGList line_uid

			view.model = model
			view.render true
			ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, "Security Group Rule"

	unLoadModule = () ->
		current_view.off()
		current_model.off()
		current_view.undelegateEvents()
		#ide_event.offListen ide_event.<EVENT_TYPE>
		#ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

	#public
	loadModule   : loadModule
	unLoadModule : unLoadModule
	loadAppModule : loadAppModule
