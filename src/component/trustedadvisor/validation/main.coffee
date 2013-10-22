define ['MC',
		'./result_vo',
		'./ec2/instance'
], ( MC, result_vo, instance ) ->

	list     : result_vo.list
	instance : instance
