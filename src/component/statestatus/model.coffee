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

        getUidByResId: ( resId ) ->



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