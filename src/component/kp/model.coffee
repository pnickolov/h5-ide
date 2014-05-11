define [ 'constant', 'backbone', 'underscore', 'MC', 'keypair_service' ], ( constant, Backbone, _, MC, keypair_service ) ->
    # Helper
    request = ( api, name, data ) ->
            username = $.cookie "usercode"
            session  = $.cookie "session_id"
            region = 'us-east-1' #Design.instance().region()

            args = [ null, username, session, region ]
            if arguments.length > 1
                args.push name

            if arguments.length > 2
                args.push data

            keypair_service[ api ].apply null, args

    successHandler = ( context ) ->
        ( res ) ->
            if res.is_error
                context.trigger 'request:error', res, context
                throw res
            else
                return res.resolved_data

    errorHandler = ( context ) ->
        ( err ) ->
            context.trigger 'request:error', err
            throw err

    setSelectedKey = ( keys, name ) ->
            _.each keys, ( key ) ->
                if key.keyName is name
                    key.selected = true
            keys


    Backbone.Model.extend
        defaults:
            keys: null
            deleting: null
            creating: null
            keyName: ''

        __haveGot: false

        initialize: ( options ) ->
            @resModel = options.resModel
            @set 'keyName', @resModel.getKeyName()

        haveGot: () ->
            if arguments.length is 1
                @__haveGot = arguments[ 0 ]
            @__haveGot

        setKey: ( name, noKey ) ->
            @resModel.setKey name, noKey

        settle: ( key, value ) ->
            if arguments.length is 1
                @trigger "change:#{key}"
            else
                @set key, value
                if _.isEqual @get( key ), value
                    @trigger "change:#{key}"


        getKeys: ->
            that = @
            @haveGot true
            @list().then(
                (res) ->
                    console.log('-----result-----');
                    that.settle 'keys', setSelectedKey( res, that.resModel.getKeyName() )
                    console.log(res);
                (err) ->

                    that.set 'keys', ''
            )


        list: () ->
            request( 'DescribeKeyPairs', null, null ).then successHandler(@), errorHandler(@)

        upload: ( name, data ) ->
            request( 'ImportKeyPair', name, data ).then successHandler(@), errorHandler(@)

        create: ( name ) ->
            request( 'CreateKeyPair', name ).then( successHandler(@), errorHandler(@) )

        remove: ( name ) ->
            request( 'DeleteKeyPair', name ).then successHandler(@), errorHandler(@)

        download: ( name ) ->
            request( 'download', name ).then(
                (res) ->
                    console.log(res);

                (err) ->
                    console.log(err);
            )








