#############################
#  View Mode for component/trustedadvisor
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

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

            if not _.isArray stateList
                stateList = [ stateList ]

            for state in stateList

                for status in state.statuses

                    if status.result isnt 'failure'
                        continue
                    if state.app_id isnt MC.canvas_data.id
                        continue

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
            component = @__getUidByResId resId

            # ServerGroup or ASG
            if component.parent
                # ServerGroup
                if component.self
                    extend.name = component.self.name
                # ASG
                else
                    extend.parent = component.parent.name
                    extend.name = resId

            else if component.self
                extend.name = component.self.name

            extend


        __getUidByResId: (resId) ->

            asgNameUIDMap = {}
            instanceIdASGNameMap = {}
            $.each MC.canvas_data.component, (idx, compObj) ->

                asgName = compObj.resource.AutoScalingGroupName
                compType = compObj.type
                compUID = compObj.uid

                if compType is 'AWS.AutoScaling.Group'
                    asgNameUIDMap[asgName] = compUID

            instanceIdASGUIDMap = {}
            $.each MC.data.resource_list[MC.canvas_data.region], (idx, resObj) ->
                if resObj and resObj.AutoScalingGroupName and resObj.Instances
                    $.each resObj.Instances.member, (idx, instanceObj) ->
                        instanceId = instanceObj.InstanceId
                        asgUID = asgNameUIDMap[resObj.AutoScalingGroupName]
                        instanceIdASGNameMap[instanceId] = asgUID

            resUID = ''
            parentComp = null
            selfComp = null
            compAry = _.keys(MC.canvas_data.component)
            loopCount = 0
            $.each MC.canvas_data.component, (idx, compObj) ->

                compType = compObj.type
                compUID = compObj.uid
                groupUID = compObj.serverGroupUid

                if compType is 'AWS.EC2.Instance'
                    instanceId = compObj.resource.InstanceId
                    if instanceId is resId
                        resUID = compUID
                        if groupUID and groupUID isnt compUID
                            parentComp = MC.canvas_data.component[groupUID]
                        selfComp = compObj
                        return false

                if (loopCount is compAry.length - 1) and not resUID
                    asgUID = instanceIdASGNameMap[resId]
                    if asgUID
                        parentComp = MC.canvas_data.component[asgUID]

                loopCount++

            parent: parentComp,
            self  : selfComp

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
