#*************************************************************************************
#* Filename     : ec2_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:09
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'ec2_service', 'ec2_vo'], ( Backbone, ec2_service, ec2_vo ) ->

    EC2Model = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : ec2_vo.ec2
        }

        ###### api ######
        #CreateTags api (define function)
        CreateTags : ( src, username, session_id, region_name, resource_ids, tags ) ->

            me = this

            src.model = me

            ec2_service.CreateTags src, username, session_id, region_name, resource_ids, tags, ( aws_result ) ->

                if !aws_result.is_error
                #CreateTags succeed

                    ec2_info = aws_result.resolved_data

                    #set vo


                else
                #CreateTags failed

                    console.log 'ec2.CreateTags failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EC2_CREATE_TAGS_RETURN', aws_result


        #DeleteTags api (define function)
        DeleteTags : ( src, username, session_id, region_name, resource_ids, tags ) ->

            me = this

            src.model = me

            ec2_service.DeleteTags src, username, session_id, region_name, resource_ids, tags, ( aws_result ) ->

                if !aws_result.is_error
                #DeleteTags succeed

                    ec2_info = aws_result.resolved_data

                    #set vo


                else
                #DeleteTags failed

                    console.log 'ec2.DeleteTags failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EC2_DELETE_TAGS_RETURN', aws_result


        #DescribeTags api (define function)
        DescribeTags : ( src, username, session_id, region_name, filters=null ) ->

            me = this

            src.model = me

            ec2_service.DescribeTags src, username, session_id, region_name, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeTags succeed

                    ec2_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeTags failed

                    console.log 'ec2.DescribeTags failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EC2_DESC_TAGS_RETURN', aws_result


        #DescribeRegions api (define function)
        DescribeRegions : ( src, username, session_id, region_names=null, filters=null ) ->

            me = this

            src.model = me

            ec2_service.DescribeRegions src, username, session_id, region_names, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeRegions succeed

                    ec2_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeRegions failed

                    console.log 'ec2.DescribeRegions failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EC2_DESC_REGIONS_RETURN', aws_result


        #DescribeAvailabilityZones api (define function)
        DescribeAvailabilityZones : ( src, username, session_id, region_name, zone_names=null, filters=null ) ->

            me = this

            src.model = me

            ec2_service.DescribeAvailabilityZones src, username, session_id, region_name, zone_names, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeAvailabilityZones succeed

                    ec2_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeAvailabilityZones failed

                    console.log 'ec2.DescribeAvailabilityZones failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    ec2_model = new EC2Model()

    #public (exposes methods)
    ec2_model

