####################################
#  Controller for design/property module
####################################
define [ 'event',
				'constant',
				'MC',
				'./module/design/property/view',
				'./module/design/property/base/main',
				'./module/design/property/base/view',
				'lib/forge/app'
				'i18n!nls/lang.js',

				'./module/design/property/stack/main',
				'./module/design/property/instance/main',
				'./module/design/property/sg/main',
				'./module/design/property/sgrule/main',
				'./module/design/property/volume/main',
				'./module/design/property/elb/main',
				'./module/design/property/az/main',
				'./module/design/property/subnet/main',
				'./module/design/property/vpc/main',
				'./module/design/property/rtb/main',
				'./module/design/property/igw/main',
				'./module/design/property/vgw/main',
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
		ide_event.onLongListen ide_event.OPEN_PROPERTY, ( type, uid ) ->

			# if resource not exist in app state
			currentState = MC.canvas.getState()
			if uid and currentState is 'app' and !MC.aws.aws.isExistResourceInApp(uid)
				notification 'error', lang.ide.PROP_MSG_ERR_RESOURCE_NOT_EXIST
				return

			view.load()

			# Load property
			# Format `type` so that PropertyBaseModule knows about it.
			# Here, type can be : ( according to the previous version of property/main )
			# - "component_asg_volume"   => Volume Property
			# - "component_asg_instance" => Instance main
			# - "component"
			# - "line"

			# If type is "component", type should be changed to `constant.AWS_RESOURCE_TYPE`
			# If type is "line", type should be changed to `PORTATYPE>PORTBTYPE`

			type = getComponentType( type, uid )

			# We cannot format the type for "component" / "line", then do not refresh the property panel
			if type is null
				return

			# Tell `PropertyBaseModule` to load corresponding property panel.
			tab_type = getTabType( tab_type )

			try
				PropertyBaseModule.load type, uid, tab_type
			catch error
				console.error "Cannot open property panel", error

			null

		### Helper Functions Start ###
		getComponentType = ( type, uid )->
			if type is "component"
				type = null # Reset type.

				if uid is ""
					type = "" # If uid is empty, show default property
				else
					comp = MC.canvas_data.component[ uid ]
					if comp
						type = comp.type
					else
						# The component is not in canvas_data.component, it should be in canvas_data.layout
						# Currently AZ is the only component that is in canvas_data.layout
						group = MC.canvas_data.layout.component.group[ uid ]
						if group
							type = group.type

			else if type is "line"
				type = null # Reset type
				if MC.canvas_data.layout.connection[uid]
					line_option = MC.canvas.lineTarget uid
					if line_option.length == 2
						type = line_option[0].port + '>' + line_option[1].port

			type

		getTabType = ( tab_type )->
			MC.canvas.getState()
			if tab_type is "app"
				tab_type = PropertyBaseModule.TYPE.App
			else if tab_type is "stack"
				tab_type = PropertyBaseModule.TYPE.Stack
			else
				if forge_app.existing_app_resource( uid )
					tab_type = PropertyBaseModule.TYPE.AppEdit
				else
					tab_type = PropertyBaseModule.TYPE.Stack

			tab_type

		### Helper Functions End ###

		### LEGACY ###
		ide_event.onLongListen ide_event.PROPERTY_OPEN_SUBPANEL, ( data ) ->
			view.showSecondPanel data
		### ###


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
