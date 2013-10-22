(function() {
  define(['MC', 'lib/ta/aws', 'lib/ta/ec2/instance', 'lib/ta/ec2/ebs', 'lib/ta/ec2/ami', 'lib/ta/elb/elb', 'lib/ta/vpn/vpn', 'lib/ta/vpc/networkacl', 'lib/ta/ec2/securitygroup', 'lib/ta/ec2/keypair', 'lib/ta/vpc/eni', 'lib/ta/vpc/vpc', 'lib/ta/vpc/subnet', 'lib/ta/vpc/rtb', 'lib/ta/autoscaling/asg', 'lib/ta/autoscaling/launchconfiguration', 'lib/ta/vpc/igw', 'lib/ta/ec2/eip'], function(MC, aws_handler, aws_handler_instance, aws_handler_ebs, aws_handler_ami, aws_handler_elb, aws_handler_vpn, aws_handler_acl, aws_handler_securitygroup, aws_handler_keypair, aws_handler_eni, aws_handler_vpc, aws_handler_subnet, aws_handler_rtb, aws_handler_asg, aws_handler_lc, aws_handler_igw, aws_handler_eip) {
    return MC.ta = {
      instance: aws_handler_instance,
      asg: aws_handler_asg,
      lc: aws_handler_lc,
      aws: aws_handler,
      ebs: aws_handler_ebs,
      ami: aws_handler_ami,
      elb: aws_handler_elb,
      vpn: aws_handler_vpn,
      acl: aws_handler_acl,
      sg: aws_handler_securitygroup,
      kp: aws_handler_keypair,
      eni: aws_handler_eni,
      vpc: aws_handler_vpc,
      subnet: aws_handler_subnet,
      rtb: aws_handler_rtb,
      igw: aws_handler_igw,
      eip: aws_handler_eip
    };
  });

}).call(this);
