#############################
#  View Mode for component/trustedadvisor
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    StateStatusModel = Backbone.Model.extend {

        defaults :
            test: null

        initialize: () ->

            that = this
            that.genStateStatusData()

        genStateStatusData: () ->

            that = this

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
                    }
                ]
            }

            statusAry = statusData.statuses

            that.set('stateStatusDataAry', statusAry)

    }

    return StateStatusModel