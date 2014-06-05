####################################
#  Controller for design/property module
####################################
define [ 'event',
				'constant',
				'MC',
				'./view',
				'./base/main',
				'./base/view',

				'i18n!nls/lang.js',

				'./stack/main',
				'./instance/main',
				'./servergroup/main',
				'./connection/main',
				'./staticsub/main',
				'./missing/main',
				'./sg/main',
				'./sgrule/main',
				'./volume/main',
				'./elb/main',
				'./az/main',
				'./subnet/main',
				'./vpc/main',
				'./rtb/main',
				'./static/main',
				'./cgw/main',
				'./vpn/main',
				'./eni/main',
				'./acl/main',
				'./launchconfig/main',
				'./asg/main'
], ( ide_event, CONST, MC, View, PropertyBaseModule, PropertyBaseView, lang ) ->

	ide_event.onLongListen ide_event.REFRESH_PROPERTY,    ()-> $canvas($canvas.selected_node()).select(); return
	ide_event.onLongListen ide_event.FORCE_OPEN_PROPERTY, (tab)-> view.forceShow(tab); return
	ide_event.onLongListen ide_event.SHOW_STATE_EDITOR,   (uid)-> view.renderState( uid, null, true ); return
	ide_event.onLongListen ide_event.OPEN_PROPERTY, openPorperty

	# Setup view / PropertyBaseView / PropertyBaseModule events.
	PropertyBaseView.event.on   PropertyBaseView.event.FORCE_SHOW,        (tab)-> view.forceShow(tab); return
	PropertyBaseView.event.on   PropertyBaseView.event.OPEN_SUBPANEL,     ()-> view.showSecondPanel(); return
	PropertyBaseView.event.on   PropertyBaseView.event.OPEN_SUBPANEL_IMM, ()-> view.immShowSecondPanel(); return
	PropertyBaseModule.event.on PropertyBaseModule.event.HIDE_SUB_PANEL,  ()-> view.immHideSecondPanel(); return


	view.on "HIDE_SUBPANEL", ()-> PropertyBaseModule.onUnloadSubPanel(); return
	view.on "GET_CURRENT_UID", ( event )->
		activeModule = PropertyBaseModule.activeModule()
		event.uid = if activeModule then activeModule.uid else ""
		null

	openPorperty = ( type, uid, force, tab ) ->
		stateStatus = view.processState uid, type

		if openTab tab, uid
			return
		if view.currentTab is 'state' and stateStatus
			view.renderState uid, type
			updateActiveModule uid, type
			null
		else
			view.renderProperty uid, type, force

	updateActiveModule = ( uid, type ) ->
		# Because snapshot is needed, and snapshot is only in property now.
		# snapshot work in state mode
		activeModule = PropertyBaseModule.activeModule()
		activeModule.uid = uid
		activeModule.comType = type
		null

	openTab = ( tab, uid ) ->
		if tab is 'property'
			view.renderProperty uid
			true
		else if tab is 'state'
			view.renderState uid
			true
		else
			false

	# Whenever tab is switched
	# Use this method to generate data for the current property
	# Then use restore() to restore the tab
	snapshot = ()->
		PropertyBaseModule.snapshot view

	restore = ( snapshot ) ->
		view.restore snapshot
		PropertyBaseModule.restore snapshot, view



	#public
	loadModule   : loadModule
	unLoadModule : unLoadModule
	snapshot     : snapshot
	restore      : restore
