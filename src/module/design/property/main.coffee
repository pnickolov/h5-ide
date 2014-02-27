####################################
#  Controller for design/property module
####################################
define [ 'event',
				'constant',
				'MC',
				'./module/design/property/view',
				'./module/design/property/base/main',
				'./module/design/property/base/view',

				"Design"
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
], ( ide_event, constant, MC, View, PropertyBaseModule, PropertyBaseView, Design, lang ) ->

	#private
	loadModule = () ->

		# Render property panel frames.
		view = new View()

		ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

		ide_event.onLongListen ide_event.FORCE_OPEN_PROPERTY, ()->
			view.forceShow()
			null

		# Setup view / PropertyBaseView / PropertyBaseModule events.
		PropertyBaseView.event.on PropertyBaseView.event.FORCE_SHOW, () ->
			view.forceShow()
			null

		PropertyBaseView.event.on PropertyBaseView.event.OPEN_SUBPANEL_IMM, () ->
			view.immShowSecondPanel()
			null

		PropertyBaseModule.event.on PropertyBaseModule.event.HIDE_SUB_PANEL, ()->
			view.immHideSecondPanel()
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
		ide_event.onLongListen ide_event.OPEN_PROPERTY, ( type, uid, force ) ->
			view.render()
			view.load()

			# Load property
			# Format `type` so that PropertyBaseModule knows about it.
			# Here, type can be : ( according to the previous version of property/main )
			# - "component_asg_volume"   => Volume Property
			# - "component_asg_instance" => Instance main
			# - "component"
			# - "stack"

			design    = Design.instance()

			# If type is "component", type should be changed to ResourceModel's type
			if uid
				component = design.component( uid )
				if component and component.type is type and design.modeIsApp() and component.get( 'appId' ) and not component.hasAppResource()
					type = 'Missing_Resource'
			else
				type = "Stack"


			# Get current model of design
			if design.modeIsApp() or design.modeIsAppView()
				tab_type = PropertyBaseModule.TYPE.App

			else if design.modeIsStack()
				tab_type = PropertyBaseModule.TYPE.Stack

			else
				# If component has associated aws resource (a.k.a has appId), it's AppEdit mode ( Partially Editable )
				# Otherwise, it's Stack mode ( Fully Editable )
				if not component or component.get("appId")
					tab_type = PropertyBaseModule.TYPE.AppEdit
				else
					tab_type = PropertyBaseModule.TYPE.Stack


			# Tell `PropertyBaseModule` to load corresponding property panel.
			### env:dev ###
			PropertyBaseModule.load type, uid, tab_type
			view.afterLoad()

			if force then view.forceShow()
			### env:dev:end ###
			### env:prod ###
			try
				PropertyBaseModule.load type, uid, tab_type
				view.afterLoad()

				if force then view.forceShow()
			catch error
				console.error error
			### env:prod:end ###

			null

	unLoadModule = () ->
		null

	# Whenever tab is switched
	# Use this method to generate data for the current property
	# Then use restore() to restore the tab
	snapshot = ()->
		#PropertyBaseModule.snapshot()

	restore = ( snapshot ) ->
		#PropertyBaseModule.restore( snapshot )



	#public
	loadModule   : loadModule
	unLoadModule : unLoadModule
	snapshot     : snapshot
	restore      : restore
