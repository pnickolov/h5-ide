define [ 'constant', 'backbone', 'underscore', 'MC', 'keypair_service', 'Design' ], ( constant, Backbone, _, MC, keypair_service, Design ) ->
    # Helper
    request = ( api, name, data ) ->
            username = $.cookie "usercode"
            session  = $.cookie "session_id"
            region = Design.instance().region()

            args = [ null, username, session, region ]
            if arguments.length > 1
                args.push name

            if arguments.length > 2
                args.push data

            keypair_service[ api ].apply null, args

    successHandler = ( context ) ->
        ( res ) ->
            if res.is_error
                throw res
            else
                return res.resolved_data or res

    errorHandler = ( context ) ->
        ( err ) ->
            err = packErrorMsg err
            context.trigger 'request:error', err
            throw err

    packErrorMsg = ( err ) ->
        msg = err.error_message
        if err.error_message
            if msg.indexOf 'Length exceeds maximum of 2048' isnt -1
                msg = 'Length exceeds maximum of 2048'

        err.error_message = msg
        err

    setSelectedKey = ( keys, name ) ->
            _.each keys, ( key ) ->
                if key.keyName is name
                    key.selected = true
            keys

    filterIllegal = ( keys ) ->
        _.reject keys, ( k ) ->
            k.keyName[ 0 ] is '@'



    Backbone.Model.extend
        defaults:
            keys: []
            deleting: null
            creating: null
            keyName: ''
            defaultKey: null

        __haveGot: false

        initialize: ( options ) ->
            @resModel = options.resModel

            if @resModel
                @set 'keyName', @resModel.getKeyName()
            ###
            else
                KpModel = Design.modelClassForType( constant.RESTYPE.KP )
                defaultKp = KpModel.getDefaultKP()
                @set 'keyName', defaultKp.get( 'appId' )
            ###

        haveGot: () ->
            if arguments.length is 1
                @__haveGot = arguments[ 0 ]
            @__haveGot

        setKey: ( name, defaultKey ) ->
            if @resModel
                @resModel.setKey name, defaultKey

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
                    if that.resModel
                        keyName = that.resModel.getKeyName()
                    ###
                    else
                        keyName = that.get 'keyName'
                    ###
                    if _.isArray res
                        keys = filterIllegal res
                        keys = setSelectedKey keys, keyName
                    else
                        keys = res.resolved_data

                    that.settle 'keys', keys or []
                (err) ->
                    that.settle 'keys', []
            )


        list: () ->
            request( 'DescribeKeyPairs', null, null ).then( successHandler(@) ).fail( errorHandler(@) )

        import: ( name, data ) ->
            that = @
            request( 'ImportKeyPair', name, data ).then( successHandler(@) ).fail( errorHandler(@) ).then ( res ) ->
                keys = that.get( 'keys' )
                keys.unshift res
                that.settle 'keys'

                res

        create: ( name ) ->
            that = @
            request( 'CreateKeyPair', name ).then( successHandler(@) ).fail( errorHandler(@) ).then ( res ) ->
                keys = that.get( 'keys' )
                keys.unshift res
                that.settle 'keys'
                res


        remove: ( name ) ->
            that = @
            request( 'DeleteKeyPair', name ).then( successHandler(@) ).fail( errorHandler(@) ).then ( res ) ->
                keys = that.get 'keys'
                keyName = res.param[ 4 ]
                that.set 'keys', _.reject keys, ( k ) ->
                    k.keyName is keyName

                res

        download: ( name ) ->
            request( 'download', name ).then(
                (res) ->
                    console.log(res);

                (err) ->
                    console.log(err);
            )








