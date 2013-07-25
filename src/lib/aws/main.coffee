define ['MC',
		'lib/aws/elb/elb',
		'lib/aws/vpn/vpn'], (MC, aws_handle_elb, aws_handle_vpn) ->
	MC.aws = {
		elb: aws_handle_elb,
		vpn: aws_handle_vpn
	}