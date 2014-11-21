define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'vpc_DescribeVpcs'                       : { type:'aws', url:'/aws/vpc/',	method:'DescribeVpcs',	params:['username', 'session_id', 'region_name', 'vpc_ids', 'filters']   },
		'vpc_DescribeAccountAttributes'          : { type:'aws', url:'/aws/vpc/',	method:'DescribeAccountAttributes',	params:['username', 'session_id', 'region_name', 'attribute_name']   },
		'vpc_DescribeVpcAttribute'               : { type:'aws', url:'/aws/vpc/',	method:'DescribeVpcAttribute',	params:['username', 'session_id', 'region_name', 'vpc_id', 'attribute']   },
		'acl_DescribeNetworkAcls'                : { type:'aws', url:'/aws/vpc/acl/',	method:'DescribeNetworkAcls',	params:['username', 'session_id', 'region_name', 'acl_ids', 'filters']   },
		'cgw_DescribeCustomerGateways'           : { type:'aws', url:'/aws/vpc/cgw/',	method:'DescribeCustomerGateways',	params:['username', 'session_id', 'region_name', 'gw_ids', 'filters']   },
		'dhcp_AssociateDhcpOptions'              : { type:'aws', url:'/aws/vpc/dhcp/',	method:'AssociateDhcpOptions',	params:['username', 'session_id', 'region_name', 'dhcp_id', 'vpc_id']   },
		'dhcp_DescribeDhcpOptions'               : { type:'aws', url:'/aws/vpc/dhcp/',	method:'DescribeDhcpOptions',	params:['username', 'session_id', 'region_name', 'dhcp_ids', 'filters']   },
		'dhcp_DeleteDhcpOptions'                 : { type:'aws', url:'/aws/vpc/dhcp/',	method:'DeleteDhcpOptions',	params:['username', 'session_id', 'region_name', 'dhcp_id']   },
		'dhcp_CreateDhcpOptions'                 : { type:'aws', url:'/aws/vpc/dhcp/',	method:'CreateDhcpOptions',	params:['username', 'session_id', 'region_name', 'dhcp_configs']   },
		'eni_DescribeNetworkInterfaces'          : { type:'aws', url:'/aws/vpc/eni/',	method:'DescribeNetworkInterfaces',	params:['username', 'session_id', 'region_name', 'eni_ids', 'filters']   },
		'eni_DescribeNetworkInterfaceAttribute'  : { type:'aws', url:'/aws/vpc/eni/',	method:'DescribeNetworkInterfaceAttribute',	params:['username', 'session_id', 'region_name', 'eni_id', 'attribute']   },
		'igw_DescribeInternetGateways'           : { type:'aws', url:'/aws/vpc/igw/',	method:'DescribeInternetGateways',	params:['username', 'session_id', 'region_name', 'gw_ids', 'filters']   },
		'rtb_DescribeRouteTables'                : { type:'aws', url:'/aws/vpc/routetable/',	method:'DescribeRouteTables',	params:['username', 'session_id', 'region_name', 'rt_ids', 'filters']   },
		'subnet_DescribeSubnets'                 : { type:'aws', url:'/aws/vpc/subnet/',	method:'DescribeSubnets',	params:['username', 'session_id', 'region_name', 'subnet_ids', 'filters']   },
		'vgw_DescribeVpnGateways'                : { type:'aws', url:'/aws/vpc/vgw/',	method:'DescribeVpnGateways',	params:['username', 'session_id', 'region_name', 'gw_ids', 'filters']   },
		'vpn_DescribeVpnConnections'             : { type:'aws', url:'/aws/vpc/vpn/',	method:'DescribeVpnConnections',	params:['username', 'session_id', 'region_name', 'vpn_ids', 'filters']   },
	}

	for ( var i in Apis ) {
		/* env:dev */
		if (ApiRequestDefs.Defs[ i ]){
			console.warn('api duplicate: ' + i);
		}
		/* env:dev:end */
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
