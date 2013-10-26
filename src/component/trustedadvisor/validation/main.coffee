define ['MC',
        './ec2/instance',
        './vpc/subnet',
        './vpc/vpc',
        './elb/elb'
], ( MC, instance, subnet, vpc, elb ) ->

        instance : instance
        subnet: subnet
        vpc : vpc
        elb : elb
