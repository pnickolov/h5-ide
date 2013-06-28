#*************************************************************************************
#* Filename     : vpn_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:18
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'vpn_service'], ( Backbone, vpn_service) ->

    VPNModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        ###### api ######
        #DescribeVpnConnections api (define function)
        DescribeVpnConnections : ( src, username, session_id, region_name, vpn_ids=null, filters=null ) ->

            me = this

            src.model = me

            vpn_service.DescribeVpnConnections src, username, session_id, region_name, vpn_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeVpnConnections succeed

                    vpn_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeVpnConnections failed

                    console.log 'vpn.DescribeVpnConnections failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'VPC_VPN_DESC_VPN_CONNS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    vpn_model = new VPNModel()

    #public (exposes methods)
    vpn_model

