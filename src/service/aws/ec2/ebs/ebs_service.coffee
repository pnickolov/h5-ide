#*************************************************************************************
#* Filename     : ebs_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:14
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	BASE_URL = '/aws/ec2/ebs/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "ebs." + api_name + " callback is null"
			return false

		try

			if ( api_name.indexOf "Volume" ) != -1
				URL = BASE_URL + "volume/"
			else if ( api_name.indexOf "Snapshot" ) != -1
				URL = BASE_URL + "snapshot/"

			MC.api {
				url     : URL
				method  : api_name
				data    : param_ary
				success : ( result, return_code ) ->

					#resolve result
					param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
					aws_result = {}
					aws_result = parser result, return_code, param_ary

					callback aws_result

				error : ( result, return_code ) ->

					aws_result = {}
					aws_result.return_code      = return_code
					aws_result.is_error         = true
					aws_result.error_message    = result.toString()

					callback aws_result
			}

		catch error
			console.log "ebs." + api_name + " error:" + error.toString()


		true
	# end of send_request

	resolvedObjectToArray = ( objs ) ->

		if objs.constructor == Array

			for obj in objs

				obj = resolvedObjectToArray obj

		if objs.constructor == Object

			if $.isEmptyObject objs

				objs = null

			for key, value of objs

				if key == 'item' and value.constructor == Object

					tmp = []

					tmp.push resolvedObjectToArray value

					objs[key] = tmp

				else if value.constructor == Object or value.constructor == Array

					objs[key] = resolvedObjectToArray value

		objs
	#///////////////// Parser for CreateVolume return  /////////////////
	#private (parser CreateVolume return)
	parserCreateVolumeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserCreateVolumeReturn


	#///////////////// Parser for DeleteVolume return  /////////////////
	#private (parser DeleteVolume return)
	parserDeleteVolumeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserDeleteVolumeReturn


	#///////////////// Parser for AttachVolume return  /////////////////
	#private (parser AttachVolume return)
	parserAttachVolumeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserAttachVolumeReturn


	#///////////////// Parser for DetachVolume return  /////////////////
	#private (parser DetachVolume return)
	parserDetachVolumeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserDetachVolumeReturn


	#///////////////// Parser for DescribeVolumes return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeVolumesResult = ( result ) ->
		#resolve result
		#return vo

		result = resolvedObjectToArray ($.xml2json ($.parseXML result[1])).DescribeVolumesResponse.volumeSet

		if result?.item?
			return result.item
		else
			return null

	#private (parser DescribeVolumes return)
	parserDescribeVolumesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeVolumesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeVolumesReturn


	#///////////////// Parser for DescribeVolumeAttribute return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeVolumeAttributeResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeVolumeAttributeResponse

	#private (parser DescribeVolumeAttribute return)
	parserDescribeVolumeAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeVolumeAttributeResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeVolumeAttributeReturn


	#///////////////// Parser for DescribeVolumeStatus return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeVolumeStatusResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeVolumeStatusResponse

	#private (parser DescribeVolumeStatus return)
	parserDescribeVolumeStatusReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeVolumeStatusResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeVolumeStatusReturn


	#///////////////// Parser for ModifyVolumeAttribute return  /////////////////
	#private (parser ModifyVolumeAttribute return)
	parserModifyVolumeAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserModifyVolumeAttributeReturn


	#///////////////// Parser for EnableVolumeIO return  /////////////////
	#private (parser EnableVolumeIO return)
	parserEnableVolumeIOReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserEnableVolumeIOReturn


	#///////////////// Parser for CreateSnapshot return  /////////////////
	#private (parser CreateSnapshot return)
	parserCreateSnapshotReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserCreateSnapshotReturn


	#///////////////// Parser for DeleteSnapshot return  /////////////////
	#private (parser DeleteSnapshot return)
	parserDeleteSnapshotReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserDeleteSnapshotReturn


	#///////////////// Parser for ModifySnapshotAttribute return  /////////////////
	#private (parser ModifySnapshotAttribute return)
	parserModifySnapshotAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserModifySnapshotAttributeReturn


	#///////////////// Parser for ResetSnapshotAttribute return  /////////////////
	#private (parser ResetSnapshotAttribute return)
	parserResetSnapshotAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserResetSnapshotAttributeReturn


	#///////////////// Parser for DescribeSnapshots return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeSnapshotsResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeSnapshotsResponse.snapshotSet

	#private (parser DescribeSnapshots return)
	parserDescribeSnapshotsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeSnapshotsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeSnapshotsReturn


	#///////////////// Parser for DescribeSnapshotAttribute return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeSnapshotAttributeResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeSnapshotAttributeResponse

	#private (parser DescribeSnapshotAttribute return)
	parserDescribeSnapshotAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeSnapshotAttributeResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeSnapshotAttributeReturn


	#############################################################

	#def CreateVolume(self, username, session_id, region_name, zone_name, snapshot_id=None, volume_size=None, volume_type=None, iops=None):
	CreateVolume = ( src, username, session_id, region_name, zone_name, snapshot_id=null, volume_size=null, volume_type=null, iops=null, callback ) ->
		send_request "CreateVolume", src, [ username, session_id, region_name, zone_name, snapshot_id, volume_size, volume_type, iops ], parserCreateVolumeReturn, callback
		true

	#def DeleteVolume(self, username, session_id, region_name, volume_id):
	DeleteVolume = ( src, username, session_id, region_name, volume_id, callback ) ->
		send_request "DeleteVolume", src, [ username, session_id, region_name, volume_id ], parserDeleteVolumeReturn, callback
		true

	#def AttachVolume(self, username, session_id, region_name, volume_id, instance_id, device):
	AttachVolume = ( src, username, session_id, region_name, volume_id, instance_id, device, callback ) ->
		send_request "AttachVolume", src, [ username, session_id, region_name, volume_id, instance_id, device ], parserAttachVolumeReturn, callback
		true

	#def DetachVolume(self, username, session_id, region_name, volume_id, instance_id=None, device=None, force=False):
	DetachVolume = ( src, username, session_id, region_name, volume_id, instance_id=null, device=null, force=false, callback ) ->
		send_request "DetachVolume", src, [ username, session_id, region_name, volume_id, instance_id, device, force ], parserDetachVolumeReturn, callback
		true

	#def DescribeVolumes(self, username, session_id, region_name, volume_ids=None, filters=None):
	DescribeVolumes = ( src, username, session_id, region_name, volume_ids=null, filters=null, callback ) ->
		send_request "DescribeVolumes", src, [ username, session_id, region_name, volume_ids, filters ], parserDescribeVolumesReturn, callback
		true

	#def DescribeVolumeAttribute(self, username, session_id, region_name, volume_id, attribute_name='autoEnableIO'):
	DescribeVolumeAttribute = ( src, username, session_id, region_name, volume_id, attribute_name='autoEnableIO', callback ) ->
		send_request "DescribeVolumeAttribute", src, [ username, session_id, region_name, volume_id, attribute_name ], parserDescribeVolumeAttributeReturn, callback
		true

	#def DescribeVolumeStatus(self, username, session_id, region_name, volume_ids, filters=None, max_result=None, next_token=None):
	DescribeVolumeStatus = ( src, username, session_id, region_name, volume_ids, filters=null, max_result=null, next_token=null, callback ) ->
		send_request "DescribeVolumeStatus", src, [ username, session_id, region_name, volume_ids, filters, max_result, next_token ], parserDescribeVolumeStatusReturn, callback
		true

	#def ModifyVolumeAttribute(self, username, session_id, region_name, volume_id, auto_enable_IO=False):
	ModifyVolumeAttribute = ( src, username, session_id, region_name, volume_id, auto_enable_IO=false, callback ) ->
		send_request "ModifyVolumeAttribute", src, [ username, session_id, region_name, volume_id, auto_enable_IO ], parserModifyVolumeAttributeReturn, callback
		true

	#def EnableVolumeIO(self, username, session_id, region_name, volume_id):
	EnableVolumeIO = ( src, username, session_id, region_name, volume_id, callback ) ->
		send_request "EnableVolumeIO", src, [ username, session_id, region_name, volume_id ], parserEnableVolumeIOReturn, callback
		true

	#def CreateSnapshot(self, username, session_id, region_name, volume_id, description=None):
	CreateSnapshot = ( src, username, session_id, region_name, volume_id, description=null, callback ) ->
		send_request "CreateSnapshot", src, [ username, session_id, region_name, volume_id, description ], parserCreateSnapshotReturn, callback
		true

	#def DeleteSnapshot(self, username, session_id, region_name, snapshot_id):
	DeleteSnapshot = ( src, username, session_id, region_name, snapshot_id, callback ) ->
		send_request "DeleteSnapshot", src, [ username, session_id, region_name, snapshot_id ], parserDeleteSnapshotReturn, callback
		true

	#def ModifySnapshotAttribute(self, username, session_id, region_name, snapshot_id, user_ids, group_names):
	ModifySnapshotAttribute = ( src, username, session_id, region_name, snapshot_id, user_ids, group_names, callback ) ->
		send_request "ModifySnapshotAttribute", src, [ username, session_id, region_name, snapshot_id, user_ids, group_names ], parserModifySnapshotAttributeReturn, callback
		true

	#def ResetSnapshotAttribute(self, username, session_id, region_name, snapshot_id, attribute_name='createVolumePermission'):
	ResetSnapshotAttribute = ( src, username, session_id, region_name, snapshot_id, attribute_name='createVolumePermission', callback ) ->
		send_request "ResetSnapshotAttribute", src, [ username, session_id, region_name, snapshot_id, attribute_name ], parserResetSnapshotAttributeReturn, callback
		true

	#def DescribeSnapshots(self, username, session_id, region_name, snapshot_ids=None, owners=None, restorable_by=None, filters=None):
	DescribeSnapshots = ( src, username, session_id, region_name, snapshot_ids=null, owners=null, restorable_by=null, filters=null, callback ) ->
		send_request "DescribeSnapshots", src, [ username, session_id, region_name, snapshot_ids, owners, restorable_by, filters ], parserDescribeSnapshotsReturn, callback
		true

	#def DescribeSnapshotAttribute(self, username, session_id, region_name, snapshot_id, attribute_name='createVolumePermission'):
	DescribeSnapshotAttribute = ( src, username, session_id, region_name, snapshot_id, attribute_name='createVolumePermission', callback ) ->
		send_request "DescribeSnapshotAttribute", src, [ username, session_id, region_name, snapshot_id, attribute_name ], parserDescribeSnapshotAttributeReturn, callback
		true


	#############################################################
	#public
	CreateVolume                 : CreateVolume
	DeleteVolume                 : DeleteVolume
	AttachVolume                 : AttachVolume
	DetachVolume                 : DetachVolume
	DescribeVolumes              : DescribeVolumes
	DescribeVolumeAttribute      : DescribeVolumeAttribute
	DescribeVolumeStatus         : DescribeVolumeStatus
	ModifyVolumeAttribute        : ModifyVolumeAttribute
	EnableVolumeIO               : EnableVolumeIO
	CreateSnapshot               : CreateSnapshot
	DeleteSnapshot               : DeleteSnapshot
	ModifySnapshotAttribute      : ModifySnapshotAttribute
	ResetSnapshotAttribute       : ResetSnapshotAttribute
	DescribeSnapshots            : DescribeSnapshots
	DescribeSnapshotAttribute    : DescribeSnapshotAttribute
	#
	resolveDescribeVolumesResult   : resolveDescribeVolumesResult
	resolveDescribeSnapshotsResult : resolveDescribeSnapshotsResult

