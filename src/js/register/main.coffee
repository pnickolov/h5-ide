
require [ 'domReady', 'router', 'i18n!nls/lang.js' ], ( domReady, router, lang ) ->

	### env:prod ###
	if window.location.protocol is 'http:' and window.location.hostname isnt 'localhost'
		currentLocation = window.location.toString()
		currentLocation = currentLocation.replace('http:', 'https:')
		window.location = currentLocation
	### env:prod:end ###

	domReady () ->

		if MC.isSupport() == false
			$(document.body).prepend '<div id="unsupported-browser"><p>VisualOps IDE does not support the browser you are using.</p> <p>For a better experience, we suggest you use the latest version of <a href=" https://www.google.com/intl/en/chrome/browser/" target="_blank">Chrome</a>, <a href=" http://www.mozilla.org/en-US/firefox/all/" target="_blank">Firefox</a> or <a href=" http://windows.microsoft.com/en-us/internet-explorer/ie-10-worldwide-languages" target="_blank">IE10</a>.</p></div>'
			
		router.initialize()

		#i18n
		Handlebars.registerHelper 'i18n', ( text ) ->
			new Handlebars.SafeString lang.register[ text ]