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

	generateDownload = ( configs, vpn_data ) ->

		vpn_data = $.xml2json $.parseXML vpn_data.customerGatewayConfiguration

		if not vpn_data
			return ""

		vpn_data = vpn_data.vpn_connection

		parse_result = _.map configs, ( config ) ->

				# Currently only one configuration type is supported
				dc_data =
					vpnConnectionId   : vpn_data['@attributes'].id   || ""
					vpnGatewayId      : vpn_data.vpn_gateway_id      || ""
					customerGatewayId : vpn_data.customer_gateway_id || ""

				dc_data.tunnel = _.map vpn_data.ipsec_tunnel, ( value, key ) ->
						cur_array = {}
						cur_array.number                                 = key + 1
						cur_array.ike_protocol_method                    = value.ike.authentication_protocol || ""
						cur_array.ike_pre_shared_key                     = value.ike.pre_shared_key || ""
						cur_array.ike_authentication_protocol_algorithm  = value.ike.authentication_protocol || ""
						cur_array.ike_encryption_protocol                = value.ike.encryption_protocol || ""
						cur_array.ike_lifetime                           = value.ike.lifetime || ""
						cur_array.ike_mode                               = value.ike.mode || ""
						cur_array.ike_perfect_forward_secrecy            = value.ike.perfect_forward_secrecy || ""
						cur_array.ipsec_protocol                         = value.ipsec.protocol || ""
						cur_array.ipsec_authentication_protocol          = value.ipsec.authentication_protocol || ""
						cur_array.ipsec_encryption_protocol              = value.ipsec.encryption_protocol || ""
						cur_array.ipsec_lifetime                         = value.ipsec.lifetime || ""
						cur_array.ipsec_mode                             = value.ipsec.mode || ""
						cur_array.ipsec_perfect_forward_secrecy          = value.ipsec.perfect_forward_secrecy || ""
						cur_array.ipsec_interval                         = value.ipsec.dead_peer_detection.interval || ""
						cur_array.ipsec_retries                          = value.ipsec.dead_peer_detection.retries || ""
						cur_array.tcp_mss_adjustment                     = value.ipsec.tcp_mss_adjustment || ""
						cur_array.clear_df_bit                           = value.ipsec.clear_df_bit || ""
						cur_array.fragmentation_before_encryption        = value.ipsec.fragmentation_before_encryption || ""
						cur_array.customer_gateway_outside_address       = value.customer_gateway.tunnel_outside_address.ip_address || ""
						cur_array.vpn_gateway_outside_address            = value.vpn_gateway.tunnel_outside_address.ip_address || ""
						cur_array.customer_gateway_inside_address        = value.customer_gateway.tunnel_inside_address.ip_address + '/' + value.customer_gateway.tunnel_inside_address.network_cidr || ""
						cur_array.vpn_gateway_inside_address             = value.vpn_gateway.tunnel_inside_address.ip_address + '/' + value.customer_gateway.tunnel_inside_address.network_cidr || ""
						cur_array.next_hop                               = value.vpn_gateway.tunnel_inside_address.ip_address || ""

						cur_array

				dc_filename = dc_data.vpnConnectionId || 'download_configuration'
				dc_data     = MC.template.configurationDownload(dc_data)

				"{\"download\":true, \"filecontent\":\"#{window.btoa(dc_data)}\", \"filename\":\"#{dc_filename}\", \"btnname\":\"#{config.name}\"}"

		"[ #{parse_result.join(',')} ]"

	#public
	addVPN	: addVPN
	delVPN	: delVPN
	generateDownload : generateDownload
