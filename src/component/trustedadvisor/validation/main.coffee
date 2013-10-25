define ['MC',
		'./ec2/instance',
        './vpc/subnet',
		'./vpc/vpc'
], ( MC, instance, subnet, vpc ) ->

	instance : instance
    subnet: subnet
	vpc : vpc
