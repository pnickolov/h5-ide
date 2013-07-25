(function() {
  define(['MC', 'lib/aws/elb/elb', 'lib/aws/vpn/vpn'], function(MC, aws_handle_elb, aws_handle_vpn) {
    MC.aws = {};
    MC.aws.elb = aws_handle_elb;
    return MC.aws.vpn = aws_handle_vpn;
  });

}).call(this);
