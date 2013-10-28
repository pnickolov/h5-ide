define ['MC',
        './ec2/instance',
        './vpc/subnet',
        './vpc/vpc',
        './elb/elb',
        './ec2/securitygroup'
], ( MC, instance, subnet, vpc, elb, sg ) ->

        instance : instance
        subnet: subnet
        vpc : vpc
        elb : elb
        sg : sg
