#############################
#  View Mode for component/trustedadvisor
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], ( constant ) ->

    StateStatusModel = Backbone.Model.extend

        initialize: () ->
            @collection = new ( @__customCollection() )

            stateList = MC.data.websocket.collection.status.find().fetch()
            @collection.set @__dispose( stateList ).models, silent: true
            @set 'items', @collection
            @set 'new', []
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

                for status in state.statuses

                    # Show failed only
                    #if status.result isnt 'failure'
                    #    continue
                    # Show current app only
                    if state.app_id isnt Design.instance().get( 'id' )
                        continue

                    # test
                    #state.res_id = 'i-a271b0bc'

                    data =
                        id      : @__genId state.res_id, status.state_id
                        appId   : state.app_id
                        resId   : state.res_id
                        stateId : status.state_id
                        time    : status.time
                        result  : status.result


                    _.extend data, @__extendComponent data.resId


                    collection.add new Backbone.Model data

            collection

        __extendComponent: ( resId ) ->
            extend = {}
            component = @__getResource resId

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


        __getResource: ( resId ) ->
            result =
                parent: null
                self: null

            Design.instance().eachComponent ( component ) ->
                groupMembers = component.groupMembers and component.groupMembers()
                resourceInList = MC.data.resource_list[ Design.instance().region() ]
                if result.parent or result.self
                    null
                if component.get( 'appId' ) is resId
                    # ServerGroup
                    if groupMembers and groupMembers.length
                        result.parent = component
                        result.self = new Backbone.Model 'name': "#{component.get 'name'}-0"
                    # Instance
                    else
                        result.self = component
                    null
                # ServerGroup
                else if groupMembers and resId in _.pluck( groupMembers, 'appId' )
                    if component.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
                        result.parent = component.parent()
                    else
                        result.parent = component
                        for index, member of groupMembers
                            if member.appId is resId
                                result.self = new Backbone.Model 'name': "#{component.get 'name'}-#{+index + 1}"
                                break
                    null

            result

        listenStateStatusUpdate: ( type, newDoc , oldDoc ) ->
            collection = @__dispose newDoc
            #diff = @diff collection, @get 'items'
            @collection.add collection.models

            #@set 'items', @collection

            null

        listenStateEditorUpdate: ( data ) ->
            resId = data.resUID
            stateIds = data.stateIds

            for stateId in stateIds
                id = @__genId resId, stateId
                @collection.get( id ) and @collection.get( id ).set 'updated', true

            null



    StateStatusModel
