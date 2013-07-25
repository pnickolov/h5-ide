(function() {
  define(['MC', 'lib/aws/elb/elb', 'lib/aws/vpn/vpn', 'lib/aws/vpc/networkacl'], function(MC, aws_handle_elb, aws_handle_vpn, aws_handle_acl) {
    return MC.aws = {
      elb: aws_handle_elb,
      vpn: aws_handle_vpn,
      acl: aws_handle_acl
    };
  });

}).call(this);
