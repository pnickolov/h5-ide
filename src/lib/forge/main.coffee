define [ 'MC', 'constant' ], ( MC, constant ) ->

	getNameById = ( app_id ) ->

		app_name = ''

		if app_id

			try

				if MC.tab[app_id]
						current_tab = MC.tab[app_id].data
					else
						current_tab = MC.canvas_data

				if current_tab
					app_name = current_tab.name

			catch e

				console.error '[getNameById] error: ' + e
				app_name = ''


		app_name

	getAmis = ( data ) ->
		console.log 'getAmis', data

		amis = []

		_.each data.component, ( item ) ->
			if item.type is 'AWS.EC2.Instance' and item.resource and item.resource.ImageId and not (item.resource.ImageId in amis)
				amis.push item.resource.ImageId

			if item.type is 'AWS.AutoScaling.LaunchConfiguration' and item.resource and item.resource.ImageId and not (item.resource.ImageId in amis)
				amis.push item.resource.ImageId

		amis

	#public
	MC.forge =
		app :
			getNameById : getNameById
			getAmis     : getAmis
	null
