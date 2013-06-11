#*************************************************************************************
#* Filename     : sdb_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:17
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'sdb_service', 'sdb_vo'], ( Backbone, sdb_service, sdb_vo ) ->

    SDBModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : sdb_vo.sdb
        }

        ###### api ######
        #DomainMetadata api (define function)
        DomainMetadata : ( src, username, session_id, region_name, doamin_name ) ->

            me = this

            src.model = me

            sdb_service.DomainMetadata src, username, session_id, region_name, doamin_name, ( aws_result ) ->

                if !aws_result.is_error
                #DomainMetadata succeed

                    sdb_info = aws_result.resolved_data

                    #set vo


                else
                #DomainMetadata failed

                    console.log 'sdb.DomainMetadata failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'SDB__DOMAIN_MDATA_RETURN', aws_result


        #GetAttributes api (define function)
        GetAttributes : ( src, username, session_id, region_name, domain_name, item_name, attribute_name=null, consistent_read=null ) ->

            me = this

            src.model = me

            sdb_service.GetAttributes src, username, session_id, region_name, domain_name, item_name, attribute_name, consistent_read, ( aws_result ) ->

                if !aws_result.is_error
                #GetAttributes succeed

                    sdb_info = aws_result.resolved_data

                    #set vo


                else
                #GetAttributes failed

                    console.log 'sdb.GetAttributes failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'SDB__GET_ATTRS_RETURN', aws_result


        #ListDomains api (define function)
        ListDomains : ( src, username, session_id, region_name, max_domains=null, next_token=null ) ->

            me = this

            src.model = me

            sdb_service.ListDomains src, username, session_id, region_name, max_domains, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #ListDomains succeed

                    sdb_info = aws_result.resolved_data

                    #set vo


                else
                #ListDomains failed

                    console.log 'sdb.ListDomains failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'SDB__LST_DOMAINS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    sdb_model = new SDBModel()

    #public (exposes methods)
    sdb_model

