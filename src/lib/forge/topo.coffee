define [ 'jquery', 'MC', 'constant' ], ( $, MC, constant ) ->

	genereateTopo = ( canvas_data ) ->

		result = {}

		switch canvas_data.platform

			when 'ec2-classic' 	then result = _genereateTopo_novpc canvas_data
			when 'default-vpc'	then result = _genereateTopo_novpc canvas_data
			when 'custom-vpc'	then result = _genereateTopo_vpc   canvas_data
			when 'ec2-vpc'		then result = _genereateTopo_vpc   canvas_data

		result



	_genereateTopo_vpc = ( canvas_data ) ->

		result = {}

		comp_data   = json_data.component
		layout_data = json_data.layout



		result



	_genereateTopo_novpc = ( canvas_data ) ->

		result = {}

		comp_data   = json_data.component
		layout_data = json_data.layout

		result


	#public
	genereateTopo : genereateTopo

