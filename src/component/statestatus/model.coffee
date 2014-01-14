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


        dispose: ( stateList ) ->
            collection = new Backbone.Collection()
            for state in stateList

                for status in state.statuses
                    #if status.result isnt 'failed'
                    #    continue
                    data =
                        id      : "#{state.res_id}|#{status.state_id}"
                        appId   : state.app_id
                        resId   : state.res_id
                        uid     : @getUidByResId state.res_id
                        time    : status.time
                        stateId : status.state_id
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

    StateStatusModel
