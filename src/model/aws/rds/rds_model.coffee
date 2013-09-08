#*************************************************************************************
#* Filename     : rds_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:53
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'rds_service', 'base_model' ], ( Backbone, _, rds_service, base_model ) ->

    RDSModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeDBEngineVersions api (define function)
        DescribeDBEngineVersions : ( src, username ) ->

            me = this

            src.model = me

            rds_service.DescribeDBEngineVersions src, username, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDBEngineVersions succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'RDS_RDS_DESC_DB_ENG_VERS_RETURN', aws_result

                else
                #DescribeDBEngineVersions failed

                    console.log 'rds.DescribeDBEngineVersions failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeOrderableDBInstanceOptions api (define function)
        DescribeOrderableDBInstanceOptions : ( src, username ) ->

            me = this

            src.model = me

            rds_service.DescribeOrderableDBInstanceOptions src, username, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeOrderableDBInstanceOptions succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'RDS_RDS_DESC_ORD_DB_INS_OPTS_RETURN', aws_result

                else
                #DescribeOrderableDBInstanceOptions failed

                    console.log 'rds.DescribeOrderableDBInstanceOptions failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeEngineDefaultParameters api (define function)
        DescribeEngineDefaultParameters : ( src, username, session_id, region_name, pg_family, marker=null, max_records=null ) ->

            me = this

            src.model = me

            rds_service.DescribeEngineDefaultParameters src, username, session_id, region_name, pg_family, marker, max_records, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeEngineDefaultParameters succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'RDS_RDS_DESC_ENG_DFT_PARAMS_RETURN', aws_result

                else
                #DescribeEngineDefaultParameters failed

                    console.log 'rds.DescribeEngineDefaultParameters failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeEvents api (define function)
        DescribeEvents : ( src, username, session_id ) ->

            me = this

            src.model = me

            rds_service.DescribeEvents src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeEvents succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'RDS_RDS_DESC_EVENTS_RETURN', aws_result

                else
                #DescribeEvents failed

                    console.log 'rds.DescribeEvents failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    rds_model = new RDSModel()

    #public (exposes methods)
    rds_model

