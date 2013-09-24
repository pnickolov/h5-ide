#*************************************************************************************
#* Filename     : ec2_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:47
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'ec2_service', 'base_model' ], ( Backbone, _, ec2_service, base_model ) ->

    EC2Model = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #CreateTags api (define function)
        CreateTags : ( src, username, session_id, region_name, resource_ids, tags ) ->

            me = this

            src.model = me

            ec2_service.CreateTags src, username, session_id, region_name, resource_ids, tags, ( aws_result ) ->

                if !aws_result.is_error
                #CreateTags succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_EC2_CREATE_TAGS_RETURN', aws_result

                else
                #CreateTags failed

                    console.log 'ec2.CreateTags failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DeleteTags api (define function)
        DeleteTags : ( src, username, session_id, region_name, resource_ids, tags ) ->

            me = this

            src.model = me

            ec2_service.DeleteTags src, username, session_id, region_name, resource_ids, tags, ( aws_result ) ->

                if !aws_result.is_error
                #DeleteTags succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_EC2_DELETE_TAGS_RETURN', aws_result

                else
                #DeleteTags failed

                    console.log 'ec2.DeleteTags failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeTags api (define function)
        DescribeTags : ( src, username, session_id, region_name, filters=null ) ->

            me = this

            src.model = me

            ec2_service.DescribeTags src, username, session_id, region_name, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeTags succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_EC2_DESC_TAGS_RETURN', aws_result

                else
                #DescribeTags failed

                    console.log 'ec2.DescribeTags failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeRegions api (define function)
        DescribeRegions : ( src, username, session_id, region_names=null, filters=null ) ->

            me = this

            src.model = me

            ec2_service.DescribeRegions src, username, session_id, region_names, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeRegions succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_EC2_DESC_REGIONS_RETURN', aws_result

                else
                #DescribeRegions failed

                    console.log 'ec2.DescribeRegions failed, error is ' + aws_result.error_message
                    #me.pub aws_result
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_EC2_DESC_REGIONS_RETURN', aws_result



        #DescribeAvailabilityZones api (define function)
        DescribeAvailabilityZones : ( src, username, session_id, region_name, zone_names=null, filters=null ) ->

            me = this

            src.model = me

            ec2_service.DescribeAvailabilityZones src, username, session_id, region_name, zone_names, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeAvailabilityZones succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN', aws_result

                else
                #DescribeAvailabilityZones failed

                    console.log 'ec2.DescribeAvailabilityZones failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    ec2_model = new EC2Model()

    #public (exposes methods)
    ec2_model

