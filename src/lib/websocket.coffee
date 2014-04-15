
#Author: Ken

define ['Meteor', 'underscore', "MC"], ( Meteor, _ ) ->

	host = "#{MC.API_HOST}/ws/"

	websocketInit = () ->

		_.extend Meteor, {

							default_connection : null

							refresh : notifyFunc = (notification) ->
						}

		Meteor._debug = ( message ) ->

			console.log.call console, message

		if Meteor.isClient

			Meteor.default_connection = Meteor.connect(host, true)

			_.each ['subscribe', 'methods', 'call', 'apply', 'status', 'reconnect'], (name) ->

				Meteor[name] = _.bind Meteor.default_connection[name], Meteor.default_connection
				return




	class WebSocket

		constructor : ->

			# create local collection

			@collection = {

				'request'			:	new Meteor.Collection "request"

				'request_detail'	:	new Meteor.Collection "request_detail"

				'stack'				:	new Meteor.Collection "stack"

				'app'				:	new Meteor.Collection "app"

				'status'			:	new Meteor.Collection "status"

				'imports'			:	new Meteor.Collection "imports"

			}

		# add a callback to specific state, true or false and a callback or nothing just return websocket status
		status : ( state = false, status_callback = null ) ->

			if status_callback

				Deps.autorun stFunc = () ->

					if Meteor.status().connected is state

						status_callback()

			else

				Meteor.status().connected

		# subscribe to remote
		sub : ( name, args..., ready_callback, error_callback ) ->

			sub_instance = Meteor.subscribe name, args..., {
				onReady: ready_callback
				onError: error_callback
			}

			sub_instance


		# unsubscribe
		# sub_instance is the return from sub()
		unsub : ( sub_instance ) ->

			console.log "Stopping subscription"

			try

				sub_instance.stop()

			catch error

				console.log "Stop subscription failed. #{error}"


	websocketInit 	: 	websocketInit
	WebSocket 		:	WebSocket
