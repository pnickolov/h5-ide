define [ 'jquery', 'MC', 'constant' ], ( $, MC, constant ) ->

	#private
	getLCLine = ( line_id ) ->

		line_target = MC.canvas_data.layout.connection[line_id]

		ports = []

		return_line_id = null

		$.each line_target.target, ( comp_uid, port_type ) ->

			if not MC.canvas_data.component[comp_uid]

				original_group_uid = MC.canvas_data.layout.component.group[comp_uid].originalId

				$.each MC.canvas_data.layout.component.node, ( c_uid, node_data )->

					if node_data.type is "AWS.AutoScaling.LaunchConfiguration" and node_data.groupUId is original_group_uid

						ports.push c_uid

			else
				ports.push comp_uid


		$.each MC.canvas_data.layout.connection, ( line_uid, line ) ->

			flag = 0

			$.each line.target, ( port_uid, port_type ) ->

				if port_uid in ports

					flag += 1

				if flag == 2

					return_line_id = line_uid

		return_line_id



	#public
	getLCLine	: getLCLine