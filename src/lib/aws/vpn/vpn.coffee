define [ 'jquery', 'MC' ], ( $, MC ) ->

	#private
	addVPN = (vgwUID, cgwUID) ->

		vpn_uid = MC.guid()

		component_data = $.extend(true, {}, MC.canvas.VPN_JSON.data)
		component_data.uid = vpn_uid
		component_data.resource.VpnGatewayId = '@' + vgwUID + '.resource.VpnGatewayId'
		component_data.resource.CustomerGatewayId = '@' + cgwUID + '.resource.CustomerGatewayId'

		MC.canvas_data.component[vpn_uid] = component_data

		null

	delVPN = (vgwUID, cgwUID) ->
		vgw_ref = '@' + vgwUID + '.resource.VpnGatewayId'
		cgw_ref = '@' + cgwUID + '.resource.CustomerGatewayId'

		for item in MC.canvas_data.component
			if item.type == 'AWS.VPC.VPNConnection' and item.resource.VpnGatewayId == vgw_ref and item.resource.CustomerGatewayId == cgw_ref
				delete MC.canvas_data.component[item.uid]
				break

	#public
	addVPN	: addVPN
	delVPN	: delVPN