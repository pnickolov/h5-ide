#############################
#  View Mode for component/trustedadvisor
#############################

define [ 'constant', 'event', 'backbone', 'jquery', 'underscore', 'MC' ], ( constant, ide_event ) ->

    StateStatusModel = Backbone.Model.extend

        initialize: () ->
            @collection = new ( @__customCollection() )

            stateList = MC.data.websocket.collection.status.find().fetch()
            @collection.set @__dispose( stateList ).models, silent: true
            @set 'items', @collection
            @set 'new', []
            @set 'stop', Design.instance().get( 'state' ) is 'Stopped'
            #test

        __collectNew: ( model ) ->
            origins = @get( 'new' )
            @set 'new', @get( 'new' ).concat model
            @

        flushNew: () ->
            @set 'new', []

        __customCollection: () ->
            parent = @
            Backbone.Collection.extend
                comparator: ( model ) ->
                    - model.get( 'time' )
                initialize: ->
                    @on 'add', parent.__collectNew, parent


        __genId: ( resId, stateId ) ->
            "#{resId}|#{stateId}"

        __dispose: ( stateList ) ->

            collection = new Backbone.Collection()
            console.log stateList
            if not _.isArray stateList
                stateList = [ stateList ]

            for state in stateList

                if state.status

                    for status, idx in state.status

                        # Show failed only
                        #if status.result isnt 'failure'
                        #    continue
                        # Show current app only
                        if state.app_id isnt Design.instance().get( 'id' )
                            continue

                        # test
                        #state.res_id = 'i-a271b0bc'



                        data =
                            id      : @__genId state.res_id, status.id
                            appId   : state.app_id
                            resId   : state.res_id
                            stateId : idx + 1
                            time    : status.time
                            result  : status.result


                        _.extend data, @__extendComponent data.resId
                        # component was deleted.
                        if not data.name
                            data.name = 'unknown'

                        if data.result is 'failure'
                            collection.add new Backbone.Model data

            collection

        __extendComponent: ( resId ) ->
            extend = {}
            component = MC.aws.aws.getCompByResIdForState resId

            # ServerGroup or ASG
            if component.parent
                # ServerGroup
                if component.self
                    extend.name = component.self.get 'name'
                # ASG
                else
                    extend.parent = component.parent.get 'name'
                    extend.name = resId

                extend.uid = component.parent.id

            else if component.self
                extend.name = component.self.get 'name'
                extend.uid = component.self.id

            extend

        listenStateStatusUpdate: ( type, newDoc , oldDoc ) ->
            collection = @__dispose newDoc
            #diff = @diff collection, @get 'items'
            @collection.add collection.models

            #@set 'items', @collection

            null

        listenStateEditorUpdate: ( data ) ->
            resId = data.resId
            stateIds = data.stateIds

            for stateId in stateIds
                id = @__genId resId, stateId
                @collection.get( id ) and @collection.get( id ).set 'updated', true

            null

        listenUpdateAppState: ( state ) ->
            if state is 'Stopped'
                @set 'stop', true
            else
                @set 'stop', false



    StateStatusModel
