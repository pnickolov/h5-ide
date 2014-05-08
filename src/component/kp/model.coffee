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

    Backbone.Model.extend
        initialize: ( options ) ->



        list: () ->
            request( 'DescribeKeyPairs', null, null ).then(
                (res) ->
                    console.log(res);

                (err) ->
                    console.log(err);
            )

        upload: ( name, data ) ->
            request( 'ImportKeyPair', name, data ).then(
                (res) ->
                    console.log(res);

                (err) ->
                    console.log(err);
            )


        create: ( name ) ->
            request( 'CreateKeyPair', name ).then(
                (res) ->
                    console.log(res);

                (err) ->
                    console.log(err);
            )


        remove: ( name ) ->
            request( 'DeleteKeyPair', name ).then(
                (res) ->
                    console.log(res);

                (err) ->
                    console.log(err);
            )

        download: ( name ) ->
            request( 'download', name ).then(
                (res) ->
                    console.log(res);

                (err) ->
                    console.log(err);
            )








