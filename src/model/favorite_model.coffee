#*************************************************************************************
#* Filename     : favorite_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 15:26:55
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'favorite_service', 'favorite_vo'], ( Backbone, favorite_service, favorite_vo ) ->

    FavoriteModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : favorite_vo.favorite
        }

        ###### api ######
        #add api (define function)
        add : ( src, username, session_id, region_name, resource ) ->

            me = this

            src.model = me

            favorite_service.add src, username, session_id, region_name, resource, ( forge_result ) ->

                if !forge_result.is_error
                #add succeed

                    favorite_info = forge_result.resolved_data

                    #set vo


                else
                #add failed

                    console.log 'favorite.add failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'FAVORITE_ADD_RETURN', forge_result


        #remove api (define function)
        remove : ( src, username, session_id, region_name, resource_ids ) ->

            me = this

            src.model = me

            favorite_service.remove src, username, session_id, region_name, resource_ids, ( forge_result ) ->

                if !forge_result.is_error
                #remove succeed

                    favorite_info = forge_result.resolved_data

                    #set vo


                else
                #remove failed

                    console.log 'favorite.remove failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'FAVORITE_REMOVE_RETURN', forge_result


        #info api (define function)
        info : ( src, username, session_id, region_name, provider='AWS', service='EC2', resource='AMI' ) ->

            me = this

            src.model = me

            favorite_service.info src, username, session_id, region_name, provider='AWS', service='EC2', resource='AMI', ( forge_result ) ->

                if !forge_result.is_error
                #info succeed

                    favorite_info = forge_result.resolved_data

                    #set vo


                else
                #info failed

                    console.log 'favorite.info failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'FAVORITE_INFO_RETURN', forge_result



    }

    #############################################################
    #private (instantiation)
    favorite_model = new FavoriteModel()

    #public (exposes methods)
    favorite_model

