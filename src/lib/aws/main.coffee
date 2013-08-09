define ['MC',
		'lib/aws/aws',
		'lib/aws/ec2/ebs',
		'lib/aws/elb/elb',
		'lib/aws/vpn/vpn',
		'lib/aws/vpc/networkacl',
		'lib/aws/ec2/securitygroup',
		'lib/aws/vpc/eni',
		'lib/aws/vpc/vpc'], (MC, aws_handler, aws_handle_ebs, aws_handle_elb, aws_handle_vpn, aws_handle_acl, aws_handle_securitygroup, aws_handle_eni, aws_handle_vpc) ->
	MC.aws = {
		aws: aws_handler,
		ebs: aws_handle_ebs,
		elb: aws_handle_elb,
		vpn: aws_handle_vpn,
		acl: aws_handle_acl,
		sg: aws_handle_securitygroup,
		eni: aws_handle_eni,
		vpc: aws_handle_vpc
	}