#*************************************************************************************
#* Filename     : public_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:03
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'public_service', 'public_vo'], ( Backbone, public_service, public_vo ) ->

    PublicModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : public_vo.data
        }

        ###### api ######
        #get_hostname api (define function)
        get_hostname : ( src, region_name, instance_id ) ->

            me = this

            src.model = me

            public_service.get_hostname src, region_name, instance_id, ( forge_result ) ->

                if !forge_result.is_error
                #get_hostname succeed

                    public_info = forge_result.resolved_data

                    #set vo


                else
                #get_hostname failed

                    console.log 'public.get_hostname failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'PUBLIC_GET__HOSTNAME_RETURN', forge_result


        #get_dns_ip api (define function)
        get_dns_ip : ( src, region_name ) ->

            me = this

            src.model = me

            public_service.get_dns_ip src, region_name, ( forge_result ) ->

                if !forge_result.is_error
                #get_dns_ip succeed

                    public_info = forge_result.resolved_data

                    #set vo


                else
                #get_dns_ip failed

                    console.log 'public.get_dns_ip failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'PUBLIC_GET__DNS__IP_RETURN', forge_result



    }

    #############################################################
    #private (instantiation)
    public_model = new PublicModel()

    #public (exposes methods)
    public_model

