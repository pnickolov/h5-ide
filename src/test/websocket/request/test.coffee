
require [ 'underscore','Meteor','WS'], ( _, Meteor, WS ) ->

	#WS.websocketInit()
	console.log 1
	subscirbed = new WS.WebSocket

	subscirbed.sub "request", 'a2Vu', '6738a80f-f22d-4281-b933-f743ca7f8a57', 'us-east-1', call = () ->

		console.log subscirbed.collection.request.find()
