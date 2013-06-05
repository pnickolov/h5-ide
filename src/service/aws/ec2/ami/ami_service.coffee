#*************************************************************************************
#* Filename     : ami_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:13
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'ami_parser', 'result_vo' ], ( MC, ami_parser, result_vo ) ->

    URL = '/aws/ec2/ami/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "ami." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, src
                    result_vo.aws_result = parser result, return_code, param_ary

                    callback result_vo.aws_result

                error : ( result, return_code ) ->

                    result_vo.aws_result.return_code      = return_code
                    result_vo.aws_result.is_error         = true
                    result_vo.aws_result.error_message    = result.toString()

                    callback result_vo.aws_result
            }

        catch error
            console.log "ami." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def CreateImage(self, username, session_id, region_name, instance_id, ami_name, ami_desc=None, no_reboot=False, bd_mappings=None):
    CreateImage = ( src, username, session_id, region_name, instance_id, ami_name, ami_desc=null, no_reboot=false, bd_mappings=null, callback ) ->
        send_request "CreateImage", src, [ username, session_id, region_name, instance_id, ami_name, ami_desc, no_reboot, bd_mappings ], ami_parser.parserCreateImageReturn, callback
        true

    #def RegisterImage(self, username, session_id, region_name, ami_name=None, ami_desc=None, location=None,
    RegisterImage = ( src, username, session_id, region_name, ami_name=null, ami_desc=null, callback ) ->
        send_request "RegisterImage", src, [ username, session_id, region_name, ami_name, ami_desc ], ami_parser.parserRegisterImageReturn, callback
        true

    #def DeregisterImage(self, username, session_id, region_name, ami_id):
    DeregisterImage = ( src, username, session_id, region_name, ami_id, callback ) ->
        send_request "DeregisterImage", src, [ username, session_id, region_name, ami_id ], ami_parser.parserDeregisterImageReturn, callback
        true

    #def ModifyImageAttribute(self, username, session_id, region_name, ami_id,
    ModifyImageAttribute = ( src, username, session_id, callback ) ->
        send_request "ModifyImageAttribute", src, [ username, session_id ], ami_parser.parserModifyImageAttributeReturn, callback
        true

    #def ResetImageAttribute(self, username, session_id, region_name, ami_id, attribute_name='launchPermission'):
    ResetImageAttribute = ( src, username, session_id, region_name, ami_id, attribute_name='launchPermission', callback ) ->
        send_request "ResetImageAttribute", src, [ username, session_id, region_name, ami_id, attribute_name ], ami_parser.parserResetImageAttributeReturn, callback
        true

    #def DescribeImageAttribute(self, username, session_id, region_name, ami_id, attribute_name):
    DescribeImageAttribute = ( src, username, session_id, region_name, ami_id, attribute_name, callback ) ->
        send_request "DescribeImageAttribute", src, [ username, session_id, region_name, ami_id, attribute_name ], ami_parser.parserDescribeImageAttributeReturn, callback
        true

    #def DescribeImages(self, username, session_id, region_name, ami_ids=None, owners=None, executable_by=None, filters=None):
    DescribeImages = ( src, username, session_id, region_name, ami_ids=null, owners=null, executable_by=null, filters=null, callback ) ->
        send_request "DescribeImages", src, [ username, session_id, region_name, ami_ids, owners, executable_by, filters ], ami_parser.parserDescribeImagesReturn, callback
        true


    #############################################################
    #public
    CreateImage                  : CreateImage
    RegisterImage                : RegisterImage
    DeregisterImage              : DeregisterImage
    ModifyImageAttribute         : ModifyImageAttribute
    ResetImageAttribute          : ResetImageAttribute
    DescribeImageAttribute       : DescribeImageAttribute
    DescribeImages               : DescribeImages

