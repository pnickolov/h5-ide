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
            @listenStateStatusList()

            ide_event.onLongListen 'STATE_STATUS_DATA_UPDATE', (type, idx, statusData) ->
                that.listenStateStatusList(type, idx, statusData)
                null

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

        listenStateStatusList: (type, idx, statusData) ->

            console.log(statusData)

            null

    StateStatusModel