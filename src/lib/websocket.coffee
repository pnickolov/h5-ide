
#Author: Ken

define ['Meteor', 'underscore'], ( Meteor, _ ) ->

	host = "211.98.26.7:3000"

	websocketInit = () ->

		_.extend Meteor, {

							default_connection : null

							refresh : notifyFunc = (notification) ->
						}

		if Meteor.isClient

			Meteor.default_connection = Meteor.connect(host, true)

			_.each ['subscribe', 'methods', 'call', 'apply', 'status', 'reconnect'], func = (name) ->

				Meteor[name] = _.bind Meteor.default_connection[name], Meteor.default_connection




	class WebSocket

		constructor : ->

			# create local collection

			@collection = {

				'request'			:	new Meteor.Collection "request"

				'request_detail'	:	new Meteor.Collection "request_detail"

				'stack'				:	new Meteor.Collection "stack"

				'app'				:	new Meteor.Collection "app"

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