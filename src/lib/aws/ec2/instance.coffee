define [ 'MC' ], ( MC) ->

	#display instance number for server group
	displayInstanceNumber = ( uid, visible ) ->

		MC.canvas.display( uid , 'instance-number-group', visible )


	#public
	displayInstanceNumber : displayInstanceNumber
