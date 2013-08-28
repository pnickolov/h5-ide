#*************************************************************************************
#* Filename     : vpn_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:56
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'vpn_service', 'base_model' ], ( Backbone, _, vpn_service, base_model ) ->

    VPNModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeVpnConnections api (define function)
        DescribeVpnConnections : ( src, username, session_id, region_name, vpn_ids=null, filters=null ) ->

            me = this

            src.model = me

            vpn_service.DescribeVpnConnections src, username, session_id, region_name, vpn_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeVpnConnections succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'VPC_VPN_DESC_VPN_CONNS_RETURN', aws_result

                else
                #DescribeVpnConnections failed

                    console.log 'vpn.DescribeVpnConnections failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    vpn_model = new VPNModel()

    #public (exposes methods)
    vpn_model

