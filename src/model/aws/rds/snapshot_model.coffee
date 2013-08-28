#*************************************************************************************
#* Filename     : snapshot_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:54
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'snapshot_service', 'base_model' ], ( Backbone, _, snapshot_service, base_model ) ->

    SnapshotModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeDBSnapshots api (define function)
        DescribeDBSnapshots : ( src, username, session_id ) ->

            me = this

            src.model = me

            snapshot_service.DescribeDBSnapshots src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDBSnapshots succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'RDS_SS_DESC_DB_SNAPSHOTS_RETURN', aws_result

                else
                #DescribeDBSnapshots failed

                    console.log 'snapshot.DescribeDBSnapshots failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    snapshot_model = new SnapshotModel()

    #public (exposes methods)
    snapshot_model

