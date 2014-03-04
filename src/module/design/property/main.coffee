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
], ( ide_event, CONST, MC, View, PropertyBaseModule, PropertyBaseView, Design, lang ) ->

	view = null

	#private
	loadModule = () ->

		# Render property panel frames.
		view = new View()

		ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

		ide_event.onLongListen ide_event.REFRESH_PROPERTY, ()->
			$canvas($canvas.selected_node()).select()
			null

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

		ide_event.onLongListen ide_event.SHOW_STATE_EDITOR, ( uid )->
			view.renderState uid
			null

		view.on "HIDE_SUBPANEL", ()->
			PropertyBaseModule.onUnloadSubPanel()
			null

		view.on "GET_CURRENT_UID", ( event )->
			activeModule = PropertyBaseModule.activeModule()
			event.uid = if activeModule then activeModule.uid else ""
			null

		#listen OPEN_PROPERTY
		ide_event.onLongListen ide_event.OPEN_PROPERTY, openPorperty

	openPorperty = ( type, uid, force, tab ) ->

		stateStatus = processState uid

		if openTab tab, uid
			return
		if view.currentTab is 'state' and stateStatus
			view.renderState uid
		else
			view.renderProperty uid, type, force

	openTab = ( tab, uid ) ->
		if tab is 'property'
			view.renderProperty uid
			true
		else if tab is 'state'
			view.renderState uid
			true
		else
			false



	unLoadModule = () ->
		null

	processState = ( uid ) ->
		uid = Design.instance().canvas.selectedNode[ 0 ] if not uid
		component = Design.instance().component uid
		typeAvai = component and _.contains [ CONST.RESTYPE.LC, CONST.RESTYPE.INSTANCE ], component.type
		opsEnabled = Design.instance().get('agent').enabled

		if opsEnabled and typeAvai
			$( '#property-panel' ).removeClass 'no-state'
			true
		else
			$( '#property-panel' ).addClass 'no-state'
			false


	# Whenever tab is switched
	# Use this method to generate data for the current property
	# Then use restore() to restore the tab
	snapshot = ()->
		PropertyBaseModule.snapshot view

	restore = ( snapshot ) ->
		PropertyBaseModule.restore snapshot, view



	#public
	loadModule   : loadModule
	unLoadModule : unLoadModule
	snapshot     : snapshot
	restore      : restore
