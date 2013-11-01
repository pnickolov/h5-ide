define ['MC',
        './ec2/instance',
        './vpc/subnet',
        './vpc/vpc',
        './elb/elb',
        './ec2/securitygroup',
        './autoscaling/asg',
        './ec2/eip',
        './ec2/az',
        './vpn/vpn',
        './vpc/igw',
        './vpc/rtb',
        './vpc/cgw'
], ( MC, instance, subnet, vpc, elb, sg, asg, eip, az, vpn, igw, rtb, cgw) ->

        instance : instance
        subnet: subnet
        vpc : vpc
        elb : elb
        sg  : sg
        asg : asg
        eip : eip
        az  : az
        vpn : vpn
        igw : igw
        rtb : rtb
        cgw : cgw