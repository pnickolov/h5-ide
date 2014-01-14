#############################
#  View Mode for component/trustedadvisor
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    StateStatusModel = Backbone.Model.extend

        defaults :
            test: null

        initialize: () ->

            that = this

            @initData()


        initData: () ->
            stateList = MC.data.websocket.collection.status.find().fetch()

            collection = new Backbone.Collection()

            collection.comparator = 'time'
            console.log stateList

            for state in stateList

                for status in state.statuses
                    data =
                        appId   : state.app_id
                        resId   : state.res_id
                        uid     : @getUidByResId state.res_id
                        stateId : status.state_id
                        time    : status.time
                        result  : status.result


                    collection.add new Backbone.Model data

            @set 'items', collection

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



            null

    StateStatusModel
