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
        './stateeditor/main'
        './state/state'


], ( MC, stack, instance, subnet, vpc, elb, sg, asg, eip, az, vgw, vpn, igw, acl, cgw, eni, stateEditor, state, stateGlobal ) ->

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
        stateEditor: stateEditor
        state: state




