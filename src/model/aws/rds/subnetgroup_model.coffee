#*************************************************************************************
#* Filename     : subnetgroup_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 15:27:10
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'subnetgroup_service', 'subnetgroup_vo'], ( Backbone, subnetgroup_service, subnetgroup_vo ) ->

    SubnetGroupModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : subnetgroup_vo.subnetgroup
        }

        ###### api ######
        #DescribeDBSubnetGroups api (define function)
        DescribeDBSubnetGroups : ( src, username, session_id, region_name, sg_name=null, marker=null, max_records=null ) ->

            me = this

            src.model = me

            subnetgroup_service.DescribeDBSubnetGroups src, username, session_id, region_name, sg_name=null, marker=null, max_records=null, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDBSubnetGroups succeed

                    subnetgroup_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeDBSubnetGroups failed

                    console.log 'subnetgroup.DescribeDBSubnetGroups failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'RDS_SNTG_DESC_DB_SNET_GRPS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    subnetgroup_model = new SubnetGroupModel()

    #public (exposes methods)
    subnetgroup_model

