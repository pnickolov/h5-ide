define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'vpc_DescribeVpcs'                       : { url:'/aws/',	method:'DescribeVpcs',	params:['username', 'session_id', 'region_name', 'vpc_ids', 'filters']   },
		'vpc_DescribeAccountAttributes'          : { url:'/aws/',	method:'DescribeAccountAttributes',	params:['username', 'session_id', 'region_name', 'attribute_name']   },
		'vpc_DescribeVpcAttribute'               : { url:'/aws/',	method:'DescribeVpcAttribute',	params:['username', 'session_id', 'region_name', 'vpc_id', 'attribute']   },
		'acl_DescribeNetworkAcls'                : { url:'/aws/acl/',	method:'DescribeNetworkAcls',	params:['username', 'session_id', 'region_name', 'acl_ids', 'filters']   },
		'cgw_DescribeCustomerGateways'           : { url:'/aws/cgw/',	method:'DescribeCustomerGateways',	params:['username', 'session_id', 'region_name', 'gw_ids', 'filters']   },
		'dhcp_DescribeDhcpOptions'               : { url:'/aws/dhcp/',	method:'DescribeDhcpOptions',	params:['username', 'session_id', 'region_name', 'dhcp_ids', 'filters']   },
		'eni_DescribeNetworkInterfaces'          : { url:'/aws/eni/',	method:'DescribeNetworkInterfaces',	params:['username', 'session_id', 'region_name', 'eni_ids', 'filters']   },
		'eni_DescribeNetworkInterfaceAttribute'  : { url:'/aws/eni/',	method:'DescribeNetworkInterfaceAttribute',	params:['username', 'session_id', 'region_name', 'eni_id', 'attribute']   },
		'igw_DescribeInternetGateways'           : { url:'/aws/igw/',	method:'DescribeInternetGateways',	params:['username', 'session_id', 'region_name', 'gw_ids', 'filters']   },
		'rtb_DescribeRouteTables'                : { url:'/aws/routetable/',	method:'DescribeRouteTables',	params:['username', 'session_id', 'region_name', 'rt_ids', 'filters']   },
		'subnet_DescribeSubnets'                 : { url:'/aws/subnet/',	method:'DescribeSubnets',	params:['username', 'session_id', 'region_name', 'subnet_ids', 'filters']   },
		'vgw_DescribeVpnGateways'                : { url:'/aws/vgw/',	method:'DescribeVpnGateways',	params:['username', 'session_id', 'region_name', 'gw_ids', 'filters']   },
		'vpn_DescribeVpnConnections'             : { url:'/aws/vpn/',	method:'DescribeVpnConnections',	params:['username', 'session_id', 'region_name', 'vpn_ids', 'filters']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
