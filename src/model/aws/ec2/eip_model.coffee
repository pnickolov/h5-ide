#*************************************************************************************
#* Filename     : eip_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 15:27:02
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'eip_service', 'eip_vo'], ( Backbone, eip_service, eip_vo ) ->

    EIPModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : eip_vo.eip
        }

        ###### api ######
        #AllocateAddress api (define function)
        AllocateAddress : ( src, username, session_id, region_name, domain=null ) ->

            me = this

            src.model = me

            eip_service.AllocateAddress src, username, session_id, region_name, domain=null, ( aws_result ) ->

                if !aws_result.is_error
                #AllocateAddress succeed

                    eip_info = aws_result.resolved_data

                    #set vo


                else
                #AllocateAddress failed

                    console.log 'eip.AllocateAddress failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EIP_ALLOCATE_ADDR_RETURN', aws_result


        #ReleaseAddress api (define function)
        ReleaseAddress : ( src, username, session_id, region_name, ip=null, allocation_id=null ) ->

            me = this

            src.model = me

            eip_service.ReleaseAddress src, username, session_id, region_name, ip=null, allocation_id=null, ( aws_result ) ->

                if !aws_result.is_error
                #ReleaseAddress succeed

                    eip_info = aws_result.resolved_data

                    #set vo


                else
                #ReleaseAddress failed

                    console.log 'eip.ReleaseAddress failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EIP_RELEASE_ADDR_RETURN', aws_result


        #AssociateAddress api (define function)
        AssociateAddress : ( src, username ) ->

            me = this

            src.model = me

            eip_service.AssociateAddress src, username, ( aws_result ) ->

                if !aws_result.is_error
                #AssociateAddress succeed

                    eip_info = aws_result.resolved_data

                    #set vo


                else
                #AssociateAddress failed

                    console.log 'eip.AssociateAddress failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EIP_ASSOCIATE_ADDR_RETURN', aws_result


        #DisassociateAddress api (define function)
        DisassociateAddress : ( src, username, session_id, region_name, ip=null, association_id=null ) ->

            me = this

            src.model = me

            eip_service.DisassociateAddress src, username, session_id, region_name, ip=null, association_id=null, ( aws_result ) ->

                if !aws_result.is_error
                #DisassociateAddress succeed

                    eip_info = aws_result.resolved_data

                    #set vo


                else
                #DisassociateAddress failed

                    console.log 'eip.DisassociateAddress failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EIP_DISASSOCIATE_ADDR_RETURN', aws_result


        #DescribeAddresses api (define function)
        DescribeAddresses : ( src, username, session_id, region_name, ips=null, allocation_ids=null, filters=null ) ->

            me = this

            src.model = me

            eip_service.DescribeAddresses src, username, session_id, region_name, ips=null, allocation_ids=null, filters=null, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeAddresses succeed

                    eip_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeAddresses failed

                    console.log 'eip.DescribeAddresses failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EIP_DESC_ADDRES_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    eip_model = new EIPModel()

    #public (exposes methods)
    eip_model

