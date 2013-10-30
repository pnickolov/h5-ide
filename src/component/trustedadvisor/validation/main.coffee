define ['MC',
        './ec2/instance',
        './vpc/subnet',
        './vpc/vpc',
        './elb/elb',
        './ec2/securitygroup',
        './autoscaling/asg',
        './ec2/eip'
], ( MC, instance, subnet, vpc, elb, sg, asg, eip) ->

        instance : instance
        subnet: subnet
        vpc : vpc
        elb : elb
        sg  : sg
        asg : asg
        eip : eip
