$(()->
	# main
	updateCSS = () ->
		random = 1
		setTimeout () ->
			if random
				random = 0
			else
				random = 1
			$('#css').attr('href', 'index.css?' + random)
			updateCSS()
		, 1000
	updateCSS()
	stateEditorView = new StateEditorView()
)