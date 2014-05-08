define [ 'constant', 'backbone', 'underscore', 'MC', 'keypair_service' ], ( constant, Backbone, _, MC, keypair_service ) ->
    Backbone.Model.extend
        initialize: ( options ) ->




        list: () ->
            username = $.cookie "usercode"
            session  = $.cookie "session_id"
            region = 'us-east-1' #Design.instance().region()

            keypair_service.list( null, username, session, region ).then(
                (res) ->
                    console.log(res);

                (err) ->
                    console.log(err);
            )

        create: () ->


