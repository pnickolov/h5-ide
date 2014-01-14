#############################
#  View Mode for component/trustedadvisor
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    StateStatusModel = Backbone.Model.extend

        defaults :
            test: null

        diff: new Backbone.Model()

        resetDiff: () ->
            @diff.clear()

        setDiff: ( attr, value ) ->
            if @diff.has attr
                @diff.get( attr ).push value
            else
                @diff.set attr, [ value ]

        initialize: () ->
            @collection = new (@customCollection())
            #@set 'items', @collection

            stateList = MC.data.websocket.collection.status.find().fetch()
            @collection.set @dispose( stateList ).models
            @set 'items', @collection
            @

        customCollection: () ->
            parent = @
            Backbone.Collection.extend
                comparator: ( model ) ->
                    - model.get( 'time' )
                initialize: () ->
                    @on 'remove', ( model ) ->
                        parent.setDiff 'remove', model
                    @on 'add', ( model ) ->
                        parent.setDiff 'add', model
                    @on 'change', ( model ) ->
                        parent.setDiff 'change', model

        flush: () ->
            _.each @diff.attributes, ( attr ) ->

        genId: ( resId, stateId ) ->
            "#{resId}|#{stateId}"

        dispose: ( stateList ) ->
            collection = new Backbone.Collection()
            for state in stateList

                for status in state.statuses
                    #if status.result isnt 'failed'
                    #    continue
                    state.res_id = 'i-8b56ad95'
                    component = @getUidByResId( state.res_id )
                    if not component
                        continue
                    data =
                        id      : @genId state.res_id, status.state_id
                        uid     : component.uid
                        appId   : state.app_id
                        resId   : state.res_id
                        stateId : status.state_id
                        name    : component.name
                        time    : status.time
                        result  : status.result


                    collection.add new Backbone.Model data

            collection

        getUidByResId: (resId) ->

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
            resCompObj = null
            compAry = _.keys(MC.canvas_data.component)
            loopCount = 0
            $.each MC.canvas_data.component, (idx, compObj) ->

                compType = compObj.type
                compUID = compObj.uid

                if compType is 'AWS.EC2.Instance'
                    instanceId = compObj.resource.InstanceId
                    if instanceId is resId
                        resUID = compUID
                        resCompObj = compObj
                        return false

                if (loopCount is compAry.length - 1) and not resUID
                    asgUID = instanceIdASGNameMap[resId]
                    if asgUID
                        resCompObj = MC.canvas_data.component[asgUID]

                loopCount++

            return resCompObj

        listenStateStatusUpdate: ( type, idx, statusData ) ->
            collection = @dispose statusData
            #diff = @diff collection, @get 'items'
            @collection.set @dispose( stateList ).models
            @set 'items', @collection

            null

        listenStateEditorUpdate: ( data ) ->
            resId = data.resUID
            stateIds = data.stateIds

            for stateId in stateIds
                id = @genId resId, stateId
                @collection.get( id ).set 'updated', true

            null



    StateStatusModel
