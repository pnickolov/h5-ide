#############################
#  View Mode for component/trustedadvisor
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    StateStatusModel = Backbone.Model.extend

        defaults :
            test: null

        initialize: () ->

            that = this

            @genStateStatusData()

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
                if resObj.AutoScalingGroupName
                    $.each resObj.Instances.member, (idx, instanceObj) ->
                        instanceId = instanceObj.InstanceId
                        asgUID = asgNameUIDMap[resObj.AutoScalingGroupName]
                        instanceIdASGNameMap[instanceId] = asgUID

            resUID = ''
            compAry = _.keys(MC.canvas_data.component)
            $.each MC.canvas_data.component, (idx, compObj) ->

                compType = compObj.type
                compUID = compObj.uid

                if compType is 'AWS.EC2.Instance'
                    instanceId = compObj.resource.InstanceId
                    if instanceId is resId
                        resUID = compUID
                        return false

                if (idx is compAry.length - 1) and not resUID
                    asgUID = instanceIdASGNameMap[resId]
                    if asgUID
                        resUID = asgUID

            return resUID

        # Mock Api
        genStateStatusData: () ->

            uuid = () ->
                Math.random().toString().slice 2, 10

            # mock data
            getStateData = () ->
                app_id: uuid(),
                res_id: uuid(),
                statuses: [
                    {
                        state_id: "1",
                        time: "2013-12-13",
                        result: "success"
                    },
                    {
                        state_id: "2",
                        time: "2013-12-14",
                        result: "failed"
                    },
                    {
                        state_id: "2",
                        time: "2013-12-14",
                        result: "failed"
                    }

                ]

            statusDatas = [ getStateData(), getStateData(), getStateData() ]

            statusAry = getStateData().statuses

            @set 'stateStatusDataAry', statusAry


        listenStateStatusUpdate: ( type, idx, statusData ) ->



            null

    StateStatusModel