define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'elb_DescribeInstanceHealth'             : { url:'/aws/elb/',	method:'DescribeInstanceHealth',	params:['username', 'session_id', 'region_name', 'elb_name', 'instance_ids']   },
		'elb_DescribeLoadBalancerPolicies'       : { url:'/aws/elb/',	method:'DescribeLoadBalancerPolicies',	params:['username', 'session_id', 'region_name', 'elb_name', 'policy_names']   },
		'elb_DescribeLoadBalancerPolicyTypes'    : { url:'/aws/elb/',	method:'DescribeLoadBalancerPolicyTypes',	params:['username', 'session_id', 'region_name', 'policy_type_names']   },
		'elb_DescribeLoadBalancers'              : { url:'/aws/elb/',	method:'DescribeLoadBalancers',	params:['username', 'session_id', 'region_name', 'elb_names', 'marker']   },
		'elb_DescribeLoadBalancerAttributes'     : { url:'/aws/elb/',	method:'DescribeLoadBalancerAttributes',	params:['username', 'session_id', 'region_name', 'elb_name']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
