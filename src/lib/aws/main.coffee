define ['MC',
		'lib/aws/elb/elb',
		'lib/aws/vpn/vpn',
		'lib/aws/vpc/networkacl',
		'lib/aws/ec2/securitygroup'], (MC, aws_handle_elb, aws_handle_vpn, aws_handle_acl, aws_handle_securitygroup) ->
	MC.aws = {
		elb: aws_handle_elb,
		vpn: aws_handle_vpn,
		acl: aws_handle_acl,
		sg: aws_handle_securitygroup
	}