define [ ], ( ) ->


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

	#public
	getNameById : getNameById
