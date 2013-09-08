#*************************************************************************************
#* Filename     : dhcp_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:55
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'dhcp_service', 'base_model' ], ( Backbone, _, dhcp_service, base_model ) ->

    DHCPModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeDhcpOptions api (define function)
        DescribeDhcpOptions : ( src, username, session_id, region_name, dhcp_ids=null, filters=null ) ->

            me = this

            src.model = me

            dhcp_service.DescribeDhcpOptions src, username, session_id, region_name, dhcp_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDhcpOptions succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'VPC_DHCP_DESC_DHCP_OPTS_RETURN', aws_result

                else
                #DescribeDhcpOptions failed

                    console.log 'dhcp.DescribeDhcpOptions failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    dhcp_model = new DHCPModel()

    #public (exposes methods)
    dhcp_model

