#*************************************************************************************
#* Filename     : rds_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 15:27:10
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'rds_service', 'rds_vo'], ( Backbone, rds_service, rds_vo ) ->

    RDSModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : rds_vo.rds
        }

        ###### api ######
        #DescribeDBEngineVersions api (define function)
        DescribeDBEngineVersions : ( src, username ) ->

            me = this

            src.model = me

            rds_service.DescribeDBEngineVersions src, username, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDBEngineVersions succeed

                    rds_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeDBEngineVersions failed

                    console.log 'rds.DescribeDBEngineVersions failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'RDS_RDS_DESC_DB_ENG_VERS_RETURN', aws_result


        #DescribeOrderableDBInstanceOptions api (define function)
        DescribeOrderableDBInstanceOptions : ( src, username ) ->

            me = this

            src.model = me

            rds_service.DescribeOrderableDBInstanceOptions src, username, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeOrderableDBInstanceOptions succeed

                    rds_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeOrderableDBInstanceOptions failed

                    console.log 'rds.DescribeOrderableDBInstanceOptions failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'RDS_RDS_DESC_ORD_DB_INS_OPTS_RETURN', aws_result


        #DescribeEngineDefaultParameters api (define function)
        DescribeEngineDefaultParameters : ( src, username, session_id, region_name, pg_family, marker=null, max_records=null ) ->

            me = this

            src.model = me

            rds_service.DescribeEngineDefaultParameters src, username, session_id, region_name, pg_family, marker=null, max_records=null, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeEngineDefaultParameters succeed

                    rds_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeEngineDefaultParameters failed

                    console.log 'rds.DescribeEngineDefaultParameters failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'RDS_RDS_DESC_ENG_DFT_PARAMS_RETURN', aws_result


        #DescribeEvents api (define function)
        DescribeEvents : ( src, username, session_id ) ->

            me = this

            src.model = me

            rds_service.DescribeEvents src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeEvents succeed

                    rds_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeEvents failed

                    console.log 'rds.DescribeEvents failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'RDS_RDS_DESC_EVENTS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    rds_model = new RDSModel()

    #public (exposes methods)
    rds_model

