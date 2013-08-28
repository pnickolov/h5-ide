#*************************************************************************************
#* Filename     : keypair_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:49
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'keypair_service', 'base_model' ], ( Backbone, _, keypair_service, base_model ) ->

    KeyPairModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #CreateKeyPair api (define function)
        CreateKeyPair : ( src, username, session_id, region_name, key_name ) ->

            me = this

            src.model = me

            keypair_service.CreateKeyPair src, username, session_id, region_name, key_name, ( aws_result ) ->

                if !aws_result.is_error
                #CreateKeyPair succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_KP_CREATE_KEY_PAIR_RETURN', aws_result

                else
                #CreateKeyPair failed

                    console.log 'keypair.CreateKeyPair failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DeleteKeyPair api (define function)
        DeleteKeyPair : ( src, username, session_id, region_name, key_name ) ->

            me = this

            src.model = me

            keypair_service.DeleteKeyPair src, username, session_id, region_name, key_name, ( aws_result ) ->

                if !aws_result.is_error
                #DeleteKeyPair succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_KP_DELETE_KEY_PAIR_RETURN', aws_result

                else
                #DeleteKeyPair failed

                    console.log 'keypair.DeleteKeyPair failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #ImportKeyPair api (define function)
        ImportKeyPair : ( src, username, session_id, region_name, key_name, key_data ) ->

            me = this

            src.model = me

            keypair_service.ImportKeyPair src, username, session_id, region_name, key_name, key_data, ( aws_result ) ->

                if !aws_result.is_error
                #ImportKeyPair succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_KP_IMPORT_KEY_PAIR_RETURN', aws_result

                else
                #ImportKeyPair failed

                    console.log 'keypair.ImportKeyPair failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeKeyPairs api (define function)
        DescribeKeyPairs : ( src, username, session_id, region_name, key_names=null, filters=null ) ->

            me = this

            src.model = me

            keypair_service.DescribeKeyPairs src, username, session_id, region_name, key_names, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeKeyPairs succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_KP_DESC_KEY_PAIRS_RETURN', aws_result

                else
                #DescribeKeyPairs failed

                    console.log 'keypair.DescribeKeyPairs failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #upload api (define function)
        upload : ( src, username, session_id, region_name, key_name, key_data ) ->

            me = this

            src.model = me

            keypair_service.upload src, username, session_id, region_name, key_name, key_data, ( aws_result ) ->

                if !aws_result.is_error
                #upload succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_KPUPLOAD_RETURN', aws_result

                else
                #upload failed

                    console.log 'keypair.upload failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #download api (define function)
        download : ( src, username, session_id, region_name, key_name ) ->

            me = this

            src.model = me

            keypair_service.download src, username, session_id, region_name, key_name, ( aws_result ) ->

                if !aws_result.is_error
                #download succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_KPDOWNLOAD_RETURN', aws_result

                else
                #download failed

                    console.log 'keypair.download failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #remove api (define function)
        remove : ( src, username, session_id, region_name, key_name ) ->

            me = this

            src.model = me

            keypair_service.remove src, username, session_id, region_name, key_name, ( aws_result ) ->

                if !aws_result.is_error
                #remove succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_KPREMOVE_RETURN', aws_result

                else
                #remove failed

                    console.log 'keypair.remove failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #list api (define function)
        list : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            keypair_service.list src, username, session_id, region_name, ( aws_result ) ->

                if !aws_result.is_error
                #list succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_KPLST_RETURN', aws_result

                else
                #list failed

                    console.log 'keypair.list failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    keypair_model = new KeyPairModel()

    #public (exposes methods)
    keypair_model

