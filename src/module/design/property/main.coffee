####################################
#  Controller for design/property module
####################################
define [ 'event',
				'constant',
				'MC',
				'./module/design/property/view',
				'./module/design/property/base/main',
				'./module/design/property/base/view',

				"./module/design/framework/Design"
				'lib/forge/app',
				'i18n!nls/lang.js',

				'./module/design/property/stack/main',
				'./module/design/property/instance/main',
				'./module/design/property/servergroup/main',
				'./module/design/property/connection/main',
				'./module/design/property/staticsub/main',
				'./module/design/property/missing/main',
				'./module/design/property/sg/main',
				'./module/design/property/sgrule/main',
				'./module/design/property/volume/main',
				'./module/design/property/elb/main',
				'./module/design/property/az/main',
				'./module/design/property/subnet/main',
				'./module/design/property/vpc/main',
				'./module/design/property/rtb/main',
				'./module/design/property/static/main',
				'./module/design/property/cgw/main',
				'./module/design/property/vpn/main',
				'./module/design/property/eni/main',
				'./module/design/property/acl/main',
				'./module/design/property/launchconfig/main',
				'./module/design/property/asg/main'
], ( ide_event, constant, MC, View, PropertyBaseModule, PropertyBaseView, forge_app, lang ) ->

	#private
	loadModule = () ->

		# Render property panel frames.
		view = new View()
		view.render()

		# Setup view / PropertyBaseView / PropertyBaseModule events.
		PropertyBaseView.event.on PropertyBaseView.event.FORCE_SHOW, () ->
			view.forceShow()
			null

		PropertyBaseView.event.on PropertyBaseView.event.OPEN_SUBPANEL, () ->
			view.showSecondPanel()
			null

		view.on "HIDE_SUBPANEL", ()->
			PropertyBaseModule.onUnloadSubPanel()
			null

		view.on "GET_CURRENT_UID", ( event )->
			activeModule = PropertyBaseModule.activeModule()
			event.uid = if activeModule then activeModule.uid else ""
			null

		#listen OPEN_PROPERTY
		ide_event.onLongListen ide_event.SHOW_PROPERTY_PANEL, () ->
			console.log 'SHOW_PROPERTY_PANEL'
			view.showPropertyPanel()

		#listen OPEN_PROPERTY
		ide_event.onLongListen ide_event.OPEN_PROPERTY, ( type, uid ) ->

			view.load()

			# Load property
			# Format `type` so that PropertyBaseModule knows about it.
			# Here, type can be : ( according to the previous version of property/main )
			# - "component_asg_volume"   => Volume Property
			# - "component_asg_instance" => Instance main
			# - "component"

			component = Design.instance().component( uid )
			if not component then return

			# If type is "component", type should be changed to ResourceModel's type
			if type is "component"
				if MC.canvas.getState() is 'app' and !component.hasAppResource()
					type = 'missing_resource'
				else
					type = component.type

			# Tell `PropertyBaseModule` to load corresponding property panel.
			tab_type = getTabType( component )

			try
				PropertyBaseModule.load type, uid, tab_type
				view.afterLoad()
			catch error
				### env:dev ###
				throw error
				### env:dev:end ###

			null

		getTabType = ( component )->
			tab_type = MC.canvas.getState()
			if tab_type is "app"
				tab_type = PropertyBaseModule.TYPE.App
			else if tab_type is "stack"
				tab_type = PropertyBaseModule.TYPE.Stack
			else
				# If component has associated aws resource (a.k.a has appId), it's AppEdit mode ( Partially Editable )
				# Otherwise, it's Stack mode ( Fully Editable )
				if component.get("appId")
					tab_type = PropertyBaseModule.TYPE.AppEdit
				else
					tab_type = PropertyBaseModule.TYPE.Stack

			tab_type

		null
		### Helper Functions End ###


	unLoadModule = () ->
		null

	# Whenever tab is switched
	# Use this method to generate data for the current property
	# Then use restore() to restore the tab
	snapshot = ()->
		PropertyBaseModule.snapshot()

	restore = ( snapshot ) ->
		PropertyBaseModule.restore( snapshot )



	#public
	loadModule   : loadModule
	unLoadModule : unLoadModule
	snapshot     : snapshot
	restore      : restore
