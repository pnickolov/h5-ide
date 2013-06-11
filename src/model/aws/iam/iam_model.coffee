#*************************************************************************************
#* Filename     : iam_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:14
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'iam_service', 'iam_vo'], ( Backbone, iam_service, iam_vo ) ->

    IAMModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : iam_vo.iam
        }

        ###### api ######
        #GetServerCertificate api (define function)
        GetServerCertificate : ( src, username, session_id, region_name, servercer_name ) ->

            me = this

            src.model = me

            iam_service.GetServerCertificate src, username, session_id, region_name, servercer_name, ( aws_result ) ->

                if !aws_result.is_error
                #GetServerCertificate succeed

                    iam_info = aws_result.resolved_data

                    #set vo


                else
                #GetServerCertificate failed

                    console.log 'iam.GetServerCertificate failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'IAM__GET_SERVER_CERTIFICATE_RETURN', aws_result


        #ListServerCertificates api (define function)
        ListServerCertificates : ( src, username, session_id, region_name, marker=null, max_items=null, path_prefix=null ) ->

            me = this

            src.model = me

            iam_service.ListServerCertificates src, username, session_id, region_name, marker, max_items, path_prefix, ( aws_result ) ->

                if !aws_result.is_error
                #ListServerCertificates succeed

                    iam_info = aws_result.resolved_data

                    #set vo


                else
                #ListServerCertificates failed

                    console.log 'iam.ListServerCertificates failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'IAM__LST_SERVER_CERTIFICATES_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    iam_model = new IAMModel()

    #public (exposes methods)
    iam_model

