define ['MC',
        '../validation/aws/stack/stack',
        '../validation/aws/ec2/instance',
        '../validation/aws/vpc/subnet',
        '../validation/aws/vpc/vpc',
        '../validation/aws/elb/elb',
        '../validation/aws/ec2/securitygroup',
        '../validation/aws/asg/asg',
        '../validation/aws/ec2/eip',
        '../validation/aws/ec2/az',
        '../validation/aws/vpc/vgw',
        '../validation/aws/vpc/vpn',
        '../validation/aws/vpc/igw',
        '../validation/aws/vpc/networkacl',
        '../validation/aws/vpc/cgw',
        '../validation/aws/vpc/eni'
        '../validation/aws/vpc/rtb'
        '../validation/aws/stateeditor/main'
        '../validation/aws/state/state'
        '../validation/aws/ec2/ebs'
        '../validation/aws/ec2/kp'
        '../validation/aws/rds/dbinstance'
        '../validation/aws/rds/og'
        '../validation/aws/rds/sbg'

        '../validation/os/osport'
        '../validation/os/ossubnet'

], ( MC,
     stack, instance, subnet, vpc, elb, sg, asg, eip, az, vgw, vpn,igw, acl,
     cgw, eni, rtb, stateEditor, state, ebs, kp, dbinstance, og, sbg,

     # Open Stack
     osport, ossubnet
   ) ->

        # AWS
        stack           : stack
        instance        : instance
        subnet          : subnet
        vpc             : vpc
        elb             : elb
        sg              : sg
        asg             : asg
        eip             : eip
        az              : az
        vgw             : vgw
        vpn             : vpn
        igw             : igw
        acl             : acl
        cgw             : cgw
        eni             : eni
        rtb             : rtb
        stateEditor     : stateEditor
        state           : state
        ebs             : ebs
        kp              : kp
        dbinstance      : dbinstance
        og              : og
        sbg             : sbg


        # Open Stack
        osport          : osport
        ossubnet        : ossubnet


