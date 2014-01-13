#############################
#  View Mode for component/trustedadvisor
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    StateStatusModel = Backbone.Model.extend

        defaults :
            test: null

        initialize: () ->

            @genStateStatusData()
            @listenStateStatusList()

        genStateStatusData: () ->

            # mock data
            statusData = {
                app_id: "",
                res_id: "",
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
            }

            statusAry = statusData.statuses

            @set 'stateStatusDataAry', statusAry

        listenStateStatusList = () ->

            MC.data.websocket.collection.status.find().fetch()
            query = MC.data.websocket.collection.status.find()
            handle = query.observeChanges {

                added   : (idx, dag) ->
                    alert(dag)

                changed : (idx, dag) ->
                    alert(dag)
            }

            null

    StateStatusModel