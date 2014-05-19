define ['MC',
        './stack/stack',
        './ec2/instance',
        './vpc/subnet',
        './vpc/vpc',
        './elb/elb',
        './ec2/securitygroup',
        './asg/asg',
        './ec2/eip',
        './ec2/az',
        './vpc/vgw',
        './vpc/vpn',
        './vpc/igw',
        './vpc/networkacl',
        './vpc/cgw',
        './vpc/eni'
        './vpc/rtb'
        './stateeditor/main'
        './state/state'
        './ec2/ebs'
        './ec2/kp'

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