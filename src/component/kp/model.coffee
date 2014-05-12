define [ 'constant', 'backbone', 'underscore', 'MC', 'keypair_service', 'Design' ], ( constant, Backbone, _, MC, keypair_service, Design ) ->
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
                return res.resolved_data or res

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

        haveGot: () ->
            if arguments.length is 1
                @__haveGot = arguments[ 0 ]
            @__haveGot

        setKey: ( name, noKey ) ->
            if @resModel
                @resModel.setKey name, noKey
            else
                @handleResourcesWithDefaultKp name, noKey

        settle: ( key, value ) ->
            if arguments.length is 1
                @trigger "change:#{key}"
            else
                @set key, value
                if _.isEqual @get( key ), value
                    @trigger "change:#{key}"

        handleResourcesWithDefaultKp: ( dkp, nokp ) ->
            resources = []

            Design.instance().eachComponent ( comp ) ->
                if comp.type in [ constant.RESTYPE.INSTANCE, constant.RESTYPE.LC ]
                    if comp.isDefaultKey()
                        comp.setKey dkp, nokp

                    resources.push comp

            resources


        getKeys: ->
            that = @
            @haveGot true
            @list().then(
                (res) ->
                    console.log('-----result-----');
                    if that.resModel
                        setSelectedKey( res, that.resModel.getKeyName() )

                    that.settle 'keys', res
                (err) ->
                    that.set 'keys', ''
            )


        list: () ->
            request( 'DescribeKeyPairs', null, null ).then successHandler(@), errorHandler(@)

        import: ( name, data ) ->
            that = @
            request( 'ImportKeyPair', name, data ).then( successHandler(@), errorHandler(@) ).then ( res ) ->
                keys = that.get 'keys'
                keys.unshift res
                that.settle 'keys'

                res

        create: ( name ) ->
            that = @
            request( 'CreateKeyPair', name ).then( successHandler(@), errorHandler(@) ).then ( res ) ->
                keys = that.get 'keys'
                keys.unshift res
                that.settle 'keys'
                res


        remove: ( name ) ->
            that = @
            request( 'DeleteKeyPair', name ).then( successHandler(@), errorHandler(@) ).then ( res ) ->
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








