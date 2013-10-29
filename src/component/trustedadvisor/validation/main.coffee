define ['MC',
        './ec2/instance',
        './vpc/subnet',
        './vpc/vpc',
        './elb/elb',
        './ec2/securitygroup',
        './autoscaling/asg'
], ( MC, instance, subnet, vpc, elb, sg, asg) ->

        instance : instance
        subnet: subnet
        vpc : vpc
        elb : elb
        sg  : sg
        asg : asg
