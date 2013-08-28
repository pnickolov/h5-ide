#*************************************************************************************
#* Filename     : placementgroup_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:50
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'placementgroup_service', 'base_model' ], ( Backbone, _, placementgroup_service, base_model ) ->

    PlacementGroupModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #CreatePlacementGroup api (define function)
        CreatePlacementGroup : ( src, username, session_id, region_name, group_name, strategy='cluster' ) ->

            me = this

            src.model = me

            placementgroup_service.CreatePlacementGroup src, username, session_id, region_name, group_name, strategy, ( aws_result ) ->

                if !aws_result.is_error
                #CreatePlacementGroup succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_PG_CREATE_PLA_GRP_RETURN', aws_result

                else
                #CreatePlacementGroup failed

                    console.log 'placementgroup.CreatePlacementGroup failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DeletePlacementGroup api (define function)
        DeletePlacementGroup : ( src, username, session_id, region_name, group_name ) ->

            me = this

            src.model = me

            placementgroup_service.DeletePlacementGroup src, username, session_id, region_name, group_name, ( aws_result ) ->

                if !aws_result.is_error
                #DeletePlacementGroup succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_PG_DELETE_PLA_GRP_RETURN', aws_result

                else
                #DeletePlacementGroup failed

                    console.log 'placementgroup.DeletePlacementGroup failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribePlacementGroups api (define function)
        DescribePlacementGroups : ( src, username, session_id, region_name, group_names=null, filters=null ) ->

            me = this

            src.model = me

            placementgroup_service.DescribePlacementGroups src, username, session_id, region_name, group_names, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribePlacementGroups succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_PG_DESC_PLA_GRPS_RETURN', aws_result

                else
                #DescribePlacementGroups failed

                    console.log 'placementgroup.DescribePlacementGroups failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    placementgroup_model = new PlacementGroupModel()

    #public (exposes methods)
    placementgroup_model

