
#Author: Ken

define ['vender/meteor/meteor', 'underscore'], ( Meteor, _ ) ->

	host = "211.98.26.7:3000"

	websocketInit = () ->

		_.extend Meteor, {
						
							default_connection : null

							refresh : notifyFunc = (notification) ->
						}

		if Meteor.isClient

			dd_url = '/'

			if typeof __meteor_runtime_config__ != 'undefined'

				if __meteor_runtime_config__.DDP_DEFAULT_CONNECTION_URL

					dd_url = __meteor_runtime_config__.DDP_DEFAULT_CONNECTION_URL

			Meteor.default_connection = Meteor.connect(host, true)

			_.each ['subscribe', 'methods', 'call', 'apply', 'status', 'reconnect'], func = (name) ->

				Meteor[name] = _.bind Meteor.default_connection[name], Meteor.default_connection

			


	class WebSocket

		constructor : ->

			# create local collection

			@collection = {

				'request'			:	new Meteor.Collection "request"

				'request_detail'	:	new Meteor.Collection "request_detail"
			}

		# subscribe to remote
		sub = ( name, args..., sub_callback, callback ) ->

			sub_instance = Meteor.subscribe name, args..., sub_callback

			Deps.autorun checkReady = (c) ->

				if sub_instance.ready()

					callback() if callback

					c.stop()

			sub_instance


		# unsubscribe
		# sub_instance is the return from sub()
		unsub = ( sub_instance ) ->

			console.log "Stopping subscription"

			try

				sub_instance.stop()

			catch error

				console.log "Stop subscription failed. #{error}"

		get = ( name ) ->

			if @collection[name] is undefined

				console.log "No such collection"

				null

			else

				@collection[name].find().fetch()




	websocketInit 	: 	websocketInit
	WebSocket 		:	WebSocket