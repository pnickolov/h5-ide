#*************************************************************************************
#* Filename     : optiongroup_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:15
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'optiongroup_service'], ( Backbone, optiongroup_service) ->

    OptionGroupModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        ###### api ######
        #DescribeOptionGroupOptions api (define function)
        DescribeOptionGroupOptions : ( src, username, session_id ) ->

            me = this

            src.model = me

            optiongroup_service.DescribeOptionGroupOptions src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeOptionGroupOptions succeed

                    optiongroup_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeOptionGroupOptions failed

                    console.log 'optiongroup.DescribeOptionGroupOptions failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'RDS_OG_DESC_OPT_GRP_OPTIONS_RETURN', aws_result


        #DescribeOptionGroups api (define function)
        DescribeOptionGroups : ( src, username, session_id ) ->

            me = this

            src.model = me

            optiongroup_service.DescribeOptionGroups src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeOptionGroups succeed

                    optiongroup_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeOptionGroups failed

                    console.log 'optiongroup.DescribeOptionGroups failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'RDS_OG_DESC_OPT_GRPS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    optiongroup_model = new OptionGroupModel()

    #public (exposes methods)
    optiongroup_model

