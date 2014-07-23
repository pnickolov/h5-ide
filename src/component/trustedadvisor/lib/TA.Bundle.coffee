define ['MC',
        '../validation/stack/stack',
        '../validation/ec2/instance',
        '../validation/vpc/subnet',
        '../validation/vpc/vpc',
        '../validation/elb/elb',
        '../validation/ec2/securitygroup',
        '../validation/asg/asg',
        '../validation/ec2/eip',
        '../validation/ec2/az',
        '../validation/vpc/vgw',
        '../validation/vpc/vpn',
        '../validation/vpc/igw',
        '../validation/vpc/networkacl',
        '../validation/vpc/cgw',
        '../validation/vpc/eni'
        '../validation/vpc/rtb'
        '../validation/stateeditor/main'
        '../validation/state/state'
        '../validation/ec2/ebs'
        '../validation/ec2/kp'

], ( MC, stack, instance, subnet, vpc, elb, sg, asg, eip, az, vgw, vpn, igw, acl, cgw, eni, rtb, stateEditor, state, ebs, kp ) ->

        stack : stack
        instance : instance
        subnet: subnet
        vpc : vpc
        elb : elb
        sg  : sg
        asg : asg
        eip : eip
        az  : az
        vgw : vgw
        vpn : vpn
        igw : igw
        acl : acl
        cgw : cgw
        eni : eni
        rtb : rtb
        stateEditor: stateEditor
        state: state
        ebs: ebs
        kp : kp