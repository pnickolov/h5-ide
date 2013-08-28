#*************************************************************************************
#* Filename     : subnetgroup_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:54
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'subnetgroup_service', 'base_model' ], ( Backbone, _, subnetgroup_service, base_model ) ->

    SubnetGroupModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeDBSubnetGroups api (define function)
        DescribeDBSubnetGroups : ( src, username, session_id, region_name, sg_name=null, marker=null, max_records=null ) ->

            me = this

            src.model = me

            subnetgroup_service.DescribeDBSubnetGroups src, username, session_id, region_name, sg_name, marker, max_records, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDBSubnetGroups succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'RDS_SNTG_DESC_DB_SNET_GRPS_RETURN', aws_result

                else
                #DescribeDBSubnetGroups failed

                    console.log 'subnetgroup.DescribeDBSubnetGroups failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    subnetgroup_model = new SubnetGroupModel()

    #public (exposes methods)
    subnetgroup_model

