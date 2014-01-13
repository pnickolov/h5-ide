#############################
#  View Mode for component/trustedadvisor
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    StateStatusModel = Backbone.Model.extend

        defaults :
            test: null

        initialize: () ->

            @genStateStatusData()


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



    StateStatusModel