#*************************************************************************************
#* Filename     : dhcp_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:17
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'dhcp_service'], ( Backbone, dhcp_service) ->

    DHCPModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        ###### api ######
        #DescribeDhcpOptions api (define function)
        DescribeDhcpOptions : ( src, username, session_id, region_name, dhcp_ids=null, filters=null ) ->

            me = this

            src.model = me

            dhcp_service.DescribeDhcpOptions src, username, session_id, region_name, dhcp_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDhcpOptions succeed

                    dhcp_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeDhcpOptions failed

                    console.log 'dhcp.DescribeDhcpOptions failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'VPC_DHCP_DESC_DHCP_OPTS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    dhcp_model = new DHCPModel()

    #public (exposes methods)
    dhcp_model

