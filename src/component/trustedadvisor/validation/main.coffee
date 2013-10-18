define ['MC',
		'./ec2/instance'], (MC, instance_handler) ->
	MC.ta = {
		instance: instance_handler
	}
