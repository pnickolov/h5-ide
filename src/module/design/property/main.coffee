####################################
#  Controller for design/property module
####################################
define [ 'jquery',
		 'text!/module/design/property/template.html',
		 'event',
		 'constant',
		 'MC'
], ( $, template, ide_event, constant, MC ) ->

	#private
	loadModule = () ->

		#add handlebars script
		#template = '<script type="text/x-handlebars-template" id="property-tmpl">' + template + '</script>'
		#load remote html template
		#$( template ).appendTo '#property-panel'

		#compile partial template
		#MC.IDEcompile 'design-property', template_data, { '.accordion-item-data' : 'accordion-item-tmpl' }

		#
		require [ './module/design/property/view',
				'./module/design/property/model',
				'./module/design/property/stack/main',
				'./module/design/property/instance/main',
				'./module/design/property/sg/main', './module/design/property/sgrule/main',
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
		], ( View, model, stack_main, instance_main, sg_main, sgrule_main, volume_main, elb_main, az_main, subnet_main, vpc_main, rtb_main, igw_main, vgw_main, cgw_main, vpn_main, eni_main, acl_main, lc_main, asg_main) ->

			current_uid = null
			tab_type = null
			MC.data.current_sub_main = null

			#view
			view  = new View { 'model' : model }
			view.render template

			#show stack property
			ide_event.onLongListen ide_event.OPEN_DESIGN, ( region_name, type ) ->
				console.log 'property:OPEN_DESIGN, type = ' + type
				#check re-render
				view.reRender template
				#
				tab_type = type
				#
				if MC.data.current_sub_main then MC.data.current_sub_main.unLoadModule()
				#
				stack_main.loadModule stack_main, type

			#listen OPEN_PROPERTY
			ide_event.onLongListen ide_event.OPEN_PROPERTY, ( type, uid, instance_expended_id, back_dom, bak_tab_type ) ->

				# Better than $("input:focus")
				$( document.activeElement ).filter( 'input, textarea' ).blur()

				# Hide second panel if there's any
				view.immHideSecondPanel()

				#backup OLD_APP and OLD_STACK start
				MC.data.last_open_property = { 'event_type' : ide_event.OPEN_PROPERTY, 'type' : type, 'uid' : uid, 'instance_expended_id' : instance_expended_id }
				if bak_tab_type             then tab_type = bak_tab_type
				if MC.data.current_sub_main then MC.data.current_sub_main.unLoadModule()
				view.back_dom = if back_dom then back_dom else 'none'
				#backup OLD_APP and OLD_STACK end

				current_uid  = uid
				console.log 'OPEN_PROPERTY, uid = ' + uid

				if type == 'component_asg_volume'
					#show asg volume property
					volume_main.loadModule uid, volume_main, tab_type

				else if type == 'component_asg_instance'
					instance_main.loadModule uid, instance_expended_id, instance_main, tab_type

				else if type == 'component'

					#show stack property
					if uid is ''
						stack_main.loadModule stack_main, tab_type

					#show az property
					if MC.canvas_data.component[ uid ]

						console.log 'type = ' + MC.canvas_data.component[ uid ].type
						#components except AvailabilityZone
						switch MC.canvas_data.component[ uid ].type
							#show instance property
							when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance         then instance_main.loadModule uid, instance_expended_id, instance_main, tab_type
							#show volume/snapshot property
							when constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume           then volume_main.loadModule uid, volume_main, tab_type
							#show elb property
							when constant.AWS_RESOURCE_TYPE.AWS_ELB                  then elb_main.loadModule uid, elb_main, tab_type
							#show subnet property
							when constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet           then subnet_main.loadModule uid, subnet_main, tab_type
							#show vpc property
							when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC              then vpc_main.loadModule uid, vpc_main, tab_type
							#show dhcp property
							when constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions      then dhcp_main.loadModule uid, dhcp_main
							#show rtb property
							when constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable       then rtb_main.loadModule uid, rtb_main, tab_type
							#show igw property
							when constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway  then igw_main.loadModule uid, igw_main
							#show vgw property
							when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway       then vgw_main.loadModule uid, vgw_main
							#show cgw property
							when constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway  then cgw_main.loadModule uid, cgw_main, tab_type
							#show vpn property
							when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection    then vpn_main.loadModule uid, null, vpn_main
							#show eni property
							when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface then eni_main.loadModule uid, eni_main, tab_type
							# Acl Property is not loaded in such a way.
							when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration then lc_main.loadModule uid, lc_main, tab_type

							when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group then asg_main.loadModule uid, asg_main, tab_type

							#
							else
								#
					else

						#AvailabilityZone
						if MC.canvas_data.layout.component.group[ uid ] and MC.canvas_data.layout.component.group[ uid ].type is constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone
							console.log 'type = ' + MC.canvas_data.layout.component.group[ uid ].type
							if tab_type is 'OPEN_APP'
								stack_main.loadModule stack_main, tab_type
							else
								az_main.loadModule uid, az_main, tab_type

				else

					#select line
					if MC.canvas_data.layout.connection[uid]

						line_option = MC.canvas.lineTarget uid

						if line_option.length == 2

							console.info line_option[0].uid + ',' + line_option[0].port + " | " + line_option[1].uid + ',' + line_option[1].port

							key = line_option[0].port + '>' + line_option[1].port


							if key.indexOf( 'rtb' ) >= 0
								#select line between instance and routetable
								for value, idx in line_option

									if value.port.indexOf('rtb-tgt') >= 0
										# rtb_main.loadModule value.uid, 'component', rtb_main
										# rtb_main.loadModule value.uid, rtb_main, tab_type
										# Delegate to RT resource
										MC.canvas.select value.uid
										break

									else if value.port.indexOf('subnet') >= 0
										rtb_main.loadModule uid, rtb_main
										break

							else if key.indexOf( "eni-attach" ) >= 0
								eni_main.loadModule uid, eni_main, tab_type

							else if key.indexOf( "subnet-assoc-in" ) >= 0
								subnet_main.loadModule uid, eni_main, tab_type

							else if key.indexOf('sg') >=0

								#select line between instance and instance
								currentState = MC.canvas.getState()

								if currentState is 'app'
									sgrule_main.loadAppModule uid
								else
									sgrule_main.loadModule uid, 'line', sgrule_main, tab_type

							else if '|vgw-vpn>cgw-vpn|cgw-vpn>vgw-vpn|'.indexOf( key ) > 0
								#select line between vgw and  cgw
								if tab_type is 'OPEN_APP'
									if line_option[1].port == "cgw-vpn"
										cgw_uid = line_option[1].uid
									else
										cgw_uid = line_option[0].uid
									# cgw_main.loadModule cgw_uid, cgw_main, tab_type
									MC.canvas.select cgw_uid
								else
									vpn_main.loadModule line_option, 'line', vpn_main

				#if back_dom then ide_event.trigger ide_event.UPDATE_PROPERTY, back_dom
				console.log 'end'

				null

			#listen OPEN_SG
			ide_event.onLongListen ide_event.OPEN_SG, ( sg_uid ) ->
				console.log 'OPEN_SG'
				sg_main.loadModule( sg_uid )
				null

			#listen OPEN_ACL
			ide_event.onLongListen ide_event.OPEN_ACL, ( acl_uid ) ->
				console.log 'OPEN_ACL'
				acl_main.loadModule( acl_uid, tab_type )
				null

			#listen SHOW_PROPERTY_PANEL
			ide_event.onLongListen ide_event.SHOW_PROPERTY_PANEL, ( ) ->
				$( '#canvas-panel' ).removeClass 'right-hiden'
				$( '#property-panel' ).removeClass 'hiden'
				null

			ide_event.onLongListen ide_event.RELOAD_PROPERTY, () ->
				view.refresh()

			#ide_event.onLongListen ide_event.UPDATE_PROPERTY, ( back_dom ) ->
			#	console.log 'UPDATE_PROPERTY'
			#	temp
			#	setTimeout () ->
			#		view.updateHtml back_dom
			#	, 500
			#

			ide_event.onLongListen ide_event.PROPERTY_TITLE_CHANGE, ( title ) ->
				view.setTitle title

			ide_event.onLongListen ide_event.PROPERTY_OPEN_SUBPANEL, ( data ) ->
				view.showSecondPanel data

			view.on "HIDE_SUBPANEL", ( id ) ->
				ide_event.trigger ide_event.PROPERTY_HIDE_SUBPANEL, id


	unLoadModule = () ->
		#view.remove()

	#public
	loadModule   : loadModule
	unLoadModule : unLoadModule
