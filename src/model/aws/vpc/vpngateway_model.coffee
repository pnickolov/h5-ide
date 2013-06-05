#*************************************************************************************
#* Filename     : vpngateway_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 15:27:12
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'vpngateway_service', 'vpngateway_vo'], ( Backbone, vpngateway_service, vpngateway_vo ) ->

    VPNGatewayModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : vpngateway_vo.vpngateway
        }

        ###### api ######
        #DescribeVpnGateways api (define function)
        DescribeVpnGateways : ( src, username, session_id, region_name, gw_ids=null, filters=null ) ->

            me = this

            src.model = me

            vpngateway_service.DescribeVpnGateways src, username, session_id, region_name, gw_ids=null, filters=null, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeVpnGateways succeed

                    vpngateway_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeVpnGateways failed

                    console.log 'vpngateway.DescribeVpnGateways failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'VPC_VGW_DESC_VPN_GWS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    vpngateway_model = new VPNGatewayModel()

    #public (exposes methods)
    vpngateway_model

