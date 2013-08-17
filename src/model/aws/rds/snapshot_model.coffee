#*************************************************************************************
#* Filename     : snapshot_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:16
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'snapshot_service'], ( Backbone, snapshot_service) ->

    SnapshotModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        ###### api ######
        #DescribeDBSnapshots api (define function)
        DescribeDBSnapshots : ( src, username, session_id ) ->

            me = this

            src.model = me

            snapshot_service.DescribeDBSnapshots src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDBSnapshots succeed

                    snapshot_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeDBSnapshots failed

                    console.log 'snapshot.DescribeDBSnapshots failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'RDS_SS_DESC_DB_SNAPSHOTS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    snapshot_model = new SnapshotModel()

    #public (exposes methods)
    snapshot_model

