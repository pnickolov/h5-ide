define([ 'i18n!/nls/lang.js', "MC.canvas" ], function( lang ){

var constant_data = {

	GRID_WIDTH: 10,
	GRID_HEIGHT: 10,

	COMPONENT_SIZE:
	{
		'AWS.ELB': [9, 9],
		'AWS.EC2.Instance': [9, 9],
		'AWS.EC2.EBS.Volume': [10, 10],
		'AWS.VPC.NetworkInterface': [9, 9],
		'AWS.VPC.CustomerGateway': [17, 10],
		'AWS.VPC.RouteTable': [8, 8],
		'AWS.VPC.InternetGateway': [8, 8],
		'AWS.VPC.VPNGateway': [8, 8],
		'AWS.AutoScaling.LaunchConfiguration': [9, 9],
		'AWS.AutoScaling.Group': [13, 13],
		'AWS.RDS.DBInstance': [10, 10]
	},

	GROUP_DEFAULT_SIZE:
	{
		'AWS.VPC.VPC': [60, 60], //[width, height]
		'AWS.EC2.AvailabilityZone': [21, 21],
		'AWS.VPC.Subnet': [17, 17],
		'AWS.RDS.SubnetGroup': [17, 17],
		'AWS.AutoScaling.Group' : [13, 13]
	},

	GROUP_PADDING: 2,

	IMAGE:
	{
		//volume icon of instance
		INSTANCE_VOLUME_ATTACHED_ACTIVE: MC.IMG_URL + 'ide/icon/instance-volume-attached-active.png',
		INSTANCE_VOLUME_ATTACHED_NORMAL: MC.IMG_URL + 'ide/icon/instance-volume-attached-normal.png',
		INSTANCE_VOLUME_NOT_ATTACHED: MC.IMG_URL + 'ide/icon/instance-volume-not-attached.png',
	},

	//min padding for group
	GROUP_MIN_PADDING: 120,

	PORT_PADDING: 4, //port padding (to point of junction)
	CORNER_RADIUS: 8, //cornerRadius of fold line

	GROUP_WEIGHT:
	{
		'AWS.VPC.VPC': ['AWS.EC2.AvailabilityZone', 'AWS.VPC.Subnet', 'AWS.AutoScaling.Group'],
		'AWS.EC2.AvailabilityZone': ['AWS.VPC.Subnet', 'AWS.AutoScaling.Group'],
		'AWS.VPC.Subnet': ['AWS.AutoScaling.Group'],
		'AWS.AutoScaling.Group': []
	},

	// If array, order by ASG -> Subnet -> AZ -> Canvas.
	MATCH_PLACEMENT:
	{
		'AWS.ELB': ['AWS.VPC.VPC'],
		'AWS.EC2.Instance': ['AWS.AutoScaling.Group', 'AWS.VPC.Subnet'],
		'AWS.EC2.EBS.Volume': ['AWS.VPC.Subnet'],
		'AWS.VPC.NetworkInterface': ['AWS.VPC.Subnet'],
		'AWS.VPC.CustomerGateway': ['Canvas'],
		'AWS.VPC.RouteTable': ['AWS.VPC.VPC'],
		'AWS.VPC.InternetGateway': ['AWS.VPC.VPC'],
		'AWS.VPC.VPNGateway': ['AWS.VPC.VPC'],
		'AWS.EC2.AvailabilityZone': ['AWS.VPC.VPC'],
		'AWS.VPC.Subnet': ['AWS.EC2.AvailabilityZone'],
		'AWS.VPC.VPC': ['Canvas'],
		'AWS.AutoScaling.Group' : ['AWS.VPC.Subnet'],
		'AWS.RDS.SubnetGroup': ['AWS.VPC.VPC'],
		'AWS.RDS.DBInstance': ['AWS.RDS.SubnetGroup']
	}
};

for ( var i in constant_data ) {
	MC.canvas[i] = constant_data[i];
}
});
