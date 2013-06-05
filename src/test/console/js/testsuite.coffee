
define [ 'MC', 'session_model' ,'jquery', 'apiList','log_model', 'public_model', 'request_model', 'app_model', 'favorite_model', 'stack_model', 'aws_model', 'ami_model', 'ebs_model', 'ec2_model', 'eip_model', 'instance_model', 'keypair_model', 'placementgroup_model', 'securitygroup_model', 'elb_model', 'iam_model', 'acl_model', 'customergateway_model', 'dhcp_model', 'eni_model', 'internetgateway_model', 'routetable_model', 'subnet_model', 'vpc_model', 'vpngateway_model', 'vpn_model',],
( MC, session_model, $, apiList, log_model, public_model, request_model, app_model, favorite_model, stack_model, aws_model, ami_model, ebs_model, ec2_model, eip_model, instance_model, keypair_model, placementgroup_model, securitygroup_model, elb_model, iam_model, acl_model, customergateway_model, dhcp_model, eni_model, internetgateway_model, routetable_model, subnet_model, vpc_model, vpngateway_model, vpn_model ) ->
	#session info

	session_id 	 = ""
	usercode	 = ""
	region_name	 = ""

	dict_request = {}
	me           = this


	#private method
	login = ( event ) ->

		event.preventDefault()

		username = $( '#login_user' ).val()
		password = $( '#login_password' ).val()

		#invoke session.login api
		session_model.login {sender: this}, username, password

		#login return handler (dispatch from service/session/session_model)
		session_model.once 'SESSION_LOGIN_RETURN', ( forge_result ) ->

			if !forge_result.is_error
			#login succeed

				session_info = forge_result.resolved_data
				session_id   = session_info.session_id
				usercode     = session_info.usercode
				region_name  = session_info.region_name

				$( "#label_login_result" ).text "login succeed, session_id : " + session_info.session_id + ", region_name : " + session_info.region_name

				$('#region_list').val session_info.region_name

				true

			else
			#login failed
				alert forge_result.error_message

				false

		true


	#private
	resolveResult = ( request_time, service, resource, api, result ) ->

		data = window.API_DATA_LIST[ service ][ resource ][ api ]
		if !result.is_error
		#DescribeInstances succeed

			$( "#label_request_result" ).text data.method + " succeed!"

			#Object to JSON, pretty print
			$( "#response_data" ).removeClass("prettyprinted").text JSON.stringify(result.resolved_data ,null,4  )
			prettyPrint()

			log_data = {
				request_time   : MC.dateFormat(request_time, "yyyy-MM-dd hh:mm:ss"),
				response_time  : MC.dateFormat(new Date(), "yyyy-MM-dd hh:mm:ss"),
				service_name   : service,
				resource_name  : resource,
				api_name       : api,
				json_ok        : "status-green",
				e_ok           : "status-green"
			}

			window.add_request_log log_data

		else
		#DescribeInstances failed

			$( "#label_request_result" ).text data.method + " failed!"
			$( "#response_data" ).text aws_result.error_message
		

	#private
	request = ( event ) ->

		event.preventDefault()

		current_api      = $( "#api_list" ).val()

		if current_api == null
			alert "Please select an api first!"
			return false

		current_service  = $( "#service_list" ).val()
		current_resource = $( "#resource_list" ).val()

		request_time     = new Date()
		response_time    = null

		key              = current_service + "-" + current_resource + "-" + current_api
		dict_request[key]= event
		

		# #instance
		# instance_model.DescribeInstances {sender: me}, usercode, session_id, region_name, null, null
		# instance_model.once "EC2_INS_DESC_INSTANCES_RETURN", ( aws_result ) ->
		# 	resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## Log ##########

		#log.put_user_log
		log_model.put_user_log {sender: me}, username, session_id, user_logs
		log_model.once "LOG_PUT__USER__LOG_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Public ##########

		#public.get_hostname
		public_model.get_hostname {sender: me}, region_name, instance_id
		public_model.once "PUBLIC_GET__HOSTNAME_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#public.get_dns_ip
		public_model.get_dns_ip {sender: me}, region_name
		public_model.once "PUBLIC_GET__DNS__IP_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Request ##########

		#request.init
		request_model.init {sender: me}, username, session_id, region_name
		request_model.once "REQUEST_INIT_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#request.update
		request_model.update {sender: me}, username, session_id, region_name, timestamp
		request_model.once "REQUEST_UPDATE_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Session ##########

		# #session.login
		# session_model.login {sender: me}, username, password
		# session_model.once "SESSION_LOGIN_RETURN", ( forge_result ) ->
		# 	resolveResult request_time, current_service, current_resource, current_api, forge_result


		#session.logout
		session_model.logout {sender: me}, username, session_id
		session_model.once "SESSION_LOGOUT_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#session.set_credential
		session_model.set_credential {sender: me}, username, session_id, access_key, secret_key, account_id
		session_model.once "SESSION_SET__CREDENTIAL_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#session.guest
		session_model.guest {sender: me}, guest_id, guestname
		session_model.once "SESSION_GUEST_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## App ##########

		#app.create
		app_model.create {sender: me}, username, session_id, region_name, spec
		app_model.once "APP_CREATE_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#app.update
		app_model.update {sender: me}, username, session_id, region_name, spec, app_id
		app_model.once "APP_UPDATE_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#app.rename
		app_model.rename {sender: me}, username, session_id, region_name, app_id, new_name, app_name
		app_model.once "APP_RENAME_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#app.terminate
		app_model.terminate {sender: me}, username, session_id, region_name, app_id, app_name
		app_model.once "APP_TERMINATE_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#app.start
		app_model.start {sender: me}, username, session_id, region_name, app_id, app_name
		app_model.once "APP_START_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#app.stop
		app_model.stop {sender: me}, username, session_id, region_name, app_id, app_name
		app_model.once "APP_STOP_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#app.reboot
		app_model.reboot {sender: me}, username, session_id, region_name, app_id, app_name
		app_model.once "APP_REBOOT_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#app.info
		app_model.info {sender: me}, username, session_id, region_name, app_ids
		app_model.once "APP_INFO_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#app.list
		app_model.list {sender: me}, username, session_id, region_name, app_ids
		app_model.once "APP_LST_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#app.resource
		app_model.resource {sender: me}, username, session_id, region_name, app_id
		app_model.once "APP_RESOURCE_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#app.summary
		app_model.summary {sender: me}, username, session_id, region_name
		app_model.once "APP_SUMMARY_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Favorite ##########

		#favorite.add
		favorite_model.add {sender: me}, username, session_id, region_name, resource
		favorite_model.once "FAVORITE_ADD_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#favorite.remove
		favorite_model.remove {sender: me}, username, session_id, region_name, resource_ids
		favorite_model.once "FAVORITE_REMOVE_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#favorite.info
		favorite_model.info {sender: me}, username, session_id, region_name, provider, service, resource
		favorite_model.once "FAVORITE_INFO_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Guest ##########

		#guest.invite
		guest_model.invite {sender: me}, username, session_id, region_name
		guest_model.once "GUEST_INVITE_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#guest.cancel
		guest_model.cancel {sender: me}, username, session_id, region_name, guest_id
		guest_model.once "GUEST_CANCEL_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#guest.access
		guest_model.access {sender: me}, guestname, session_id, region_name, guest_id
		guest_model.once "GUEST_ACCESS_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#guest.end
		guest_model.end {sender: me}, guestname, session_id, region_name, guest_id
		guest_model.once "GUEST_END_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#guest.info
		guest_model.info {sender: me}, username, session_id, region_name, guest_id
		guest_model.once "GUEST_INFO_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Stack ##########

		#stack.create
		stack_model.create {sender: me}, username, session_id, region_name, spec
		stack_model.once "STACK_CREATE_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#stack.remove
		stack_model.remove {sender: me}, username, session_id, region_name, stack_id, stack_name
		stack_model.once "STACK_REMOVE_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#stack.save
		stack_model.save {sender: me}, username, session_id, region_name, spec
		stack_model.once "STACK_SAVE_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#stack.rename
		stack_model.rename {sender: me}, username, session_id, region_name, stack_id, new_name, stack_name
		stack_model.once "STACK_RENAME_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#stack.run
		stack_model.run {sender: me}, username, session_id, region_name, stack_id, app_name, app_desc, app_component, app_property, app_layout, stack_name
		stack_model.once "STACK_RUN_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#stack.save_as
		stack_model.save_as {sender: me}, username, session_id, region_name, stack_id, new_name, stack_name
		stack_model.once "STACK_SAVE__AS_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#stack.info
		stack_model.info {sender: me}, username, session_id, region_name, stack_ids
		stack_model.once "STACK_INFO_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result


		#stack.list
		stack_model.list {sender: me}, username, session_id, region_name, stack_ids
		stack_model.once "STACK_LST_RETURN", ( forge_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## AutoScaling ##########

		#autoscaling.DescribeAdjustmentTypes
		autoscaling_model.DescribeAdjustmentTypes {sender: me}, username, session_id, region_name
		autoscaling_model.once "ASL__DESC_ADJT_TYPS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#autoscaling.DescribeAutoScalingGroups
		autoscaling_model.DescribeAutoScalingGroups {sender: me}, username, session_id, region_name, group_names, max_records, next_token
		autoscaling_model.once "ASL__DESC_ASL_GRPS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#autoscaling.DescribeAutoScalingInstances
		autoscaling_model.DescribeAutoScalingInstances {sender: me}, username, session_id, region_name, instance_ids, max_records, next_token
		autoscaling_model.once "ASL__DESC_ASL_INSS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#autoscaling.DescribeAutoScalingNotificationTypes
		autoscaling_model.DescribeAutoScalingNotificationTypes {sender: me}, username, session_id, region_name
		autoscaling_model.once "ASL__DESC_ASL_NTF_TYPS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#autoscaling.DescribeLaunchConfigurations
		autoscaling_model.DescribeLaunchConfigurations {sender: me}, username, session_id, region_name, config_names, max_records, next_token
		autoscaling_model.once "ASL__DESC_LAUNCH_CONFS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#autoscaling.DescribeMetricCollectionTypes
		autoscaling_model.DescribeMetricCollectionTypes {sender: me}, username, session_id, region_name
		autoscaling_model.once "ASL__DESC_METRIC_COLL_TYPS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#autoscaling.DescribeNotificationConfigurations
		autoscaling_model.DescribeNotificationConfigurations {sender: me}, username, session_id, region_name, group_names, max_records, next_token
		autoscaling_model.once "ASL__DESC_NTF_CONFS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#autoscaling.DescribePolicies
		autoscaling_model.DescribePolicies {sender: me}, username, session_id, region_name, group_name, policy_names, max_records, next_token
		autoscaling_model.once "ASL__DESC_PCYS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#autoscaling.DescribeScalingActivities
		autoscaling_model.DescribeScalingActivities {sender: me}, username, session_id
		autoscaling_model.once "ASL__DESC_SCALING_ACTIS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#autoscaling.DescribeScalingProcessTypes
		autoscaling_model.DescribeScalingProcessTypes {sender: me}, username, session_id, region_name
		autoscaling_model.once "ASL__DESC_SCALING_PRC_TYPS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#autoscaling.DescribeScheduledActions
		autoscaling_model.DescribeScheduledActions {sender: me}, username, session_id
		autoscaling_model.once "ASL__DESC_SCHD_ACTS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#autoscaling.DescribeTags
		autoscaling_model.DescribeTags {sender: me}, username, session_id, region_name, filters, max_records, next_token
		autoscaling_model.once "ASL__DESC_TAGS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## AWS ##########

		#aws.quickstart
		aws_model.quickstart {sender: me}, username, session_id, region_name
		aws_model.once "AWS_QUICKSTART_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#aws.Public
		aws_model.Public {sender: me}, username, session_id, region_name
		aws_model.once "AWS__PUBLIC_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#aws.info
		aws_model.info {sender: me}, username, session_id, region_name
		aws_model.once "AWS_INFO_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#aws.resource
		aws_model.resource {sender: me}, username, session_id, region_name, resources
		aws_model.once "AWS_RESOURCE_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#aws.price
		aws_model.price {sender: me}, username, session_id
		aws_model.once "AWS_PRICE_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#aws.status
		aws_model.status {sender: me}, username, session_id
		aws_model.once "AWS_STATUS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## CloudWatch ##########

		#cloudwatch.GetMetricStatistics
		cloudwatch_model.GetMetricStatistics {sender: me}, username, session_id
		cloudwatch_model.once "CW__GET_METRIC_STATS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#cloudwatch.ListMetrics
		cloudwatch_model.ListMetrics {sender: me}, username, session_id
		cloudwatch_model.once "CW__LST_METRICS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#cloudwatch.DescribeAlarmHistory
		cloudwatch_model.DescribeAlarmHistory {sender: me}, username, session_id
		cloudwatch_model.once "CW__DESC_ALM_HIST_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#cloudwatch.DescribeAlarms
		cloudwatch_model.DescribeAlarms {sender: me}, username, session_id
		cloudwatch_model.once "CW__DESC_ALMS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#cloudwatch.DescribeAlarmsForMetric
		cloudwatch_model.DescribeAlarmsForMetric {sender: me}, username, session_id
		cloudwatch_model.once "CW__DESC_ALMS_FOR_METRIC_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## AMI ##########

		#ami.CreateImage
		ami_model.CreateImage {sender: me}, username, session_id, region_name, instance_id, ami_name, ami_desc, no_reboot, bd_mappings
		ami_model.once "EC2_AMI_CREATE_IMAGE_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ami.RegisterImage
		ami_model.RegisterImage {sender: me}, username, session_id, region_name, ami_name, ami_desc
		ami_model.once "EC2_AMI_REGISTER_IMAGE_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ami.DeregisterImage
		ami_model.DeregisterImage {sender: me}, username, session_id, region_name, ami_id
		ami_model.once "EC2_AMI_DEREGISTER_IMAGE_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ami.ModifyImageAttribute
		ami_model.ModifyImageAttribute {sender: me}, username, session_id
		ami_model.once "EC2_AMI_MODIFY_IMAGE_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ami.ResetImageAttribute
		ami_model.ResetImageAttribute {sender: me}, username, session_id, region_name, ami_id, attribute_name
		ami_model.once "EC2_AMI_RESET_IMAGE_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ami.DescribeImageAttribute
		ami_model.DescribeImageAttribute {sender: me}, username, session_id, region_name, ami_id, attribute_name
		ami_model.once "EC2_AMI_DESC_IMAGE_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ami.DescribeImages
		ami_model.DescribeImages {sender: me}, username, session_id, region_name, ami_ids, owners, executable_by, filters
		ami_model.once "EC2_AMI_DESC_IMAGES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## EBS ##########

		#ebs.CreateVolume
		ebs_model.CreateVolume {sender: me}, username, session_id, region_name, zone_name, snapshot_id, volume_size, volume_type, iops
		ebs_model.once "EC2_EBS_CREATE_VOL_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.DeleteVolume
		ebs_model.DeleteVolume {sender: me}, username, session_id, region_name, volume_id
		ebs_model.once "EC2_EBS_DELETE_VOL_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.AttachVolume
		ebs_model.AttachVolume {sender: me}, username, session_id, region_name, volume_id, instance_id, device
		ebs_model.once "EC2_EBS_ATTACH_VOL_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.DetachVolume
		ebs_model.DetachVolume {sender: me}, username, session_id, region_name, volume_id, instance_id, device, force
		ebs_model.once "EC2_EBS_DETACH_VOL_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.DescribeVolumes
		ebs_model.DescribeVolumes {sender: me}, username, session_id, region_name, volume_ids, filters
		ebs_model.once "EC2_EBS_DESC_VOLS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.DescribeVolumeAttribute
		ebs_model.DescribeVolumeAttribute {sender: me}, username, session_id, region_name, volume_id, attribute_name
		ebs_model.once "EC2_EBS_DESC_VOL_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.DescribeVolumeStatus
		ebs_model.DescribeVolumeStatus {sender: me}, username, session_id, region_name, volume_ids, filters, max_result, next_token
		ebs_model.once "EC2_EBS_DESC_VOL_STATUS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.ModifyVolumeAttribute
		ebs_model.ModifyVolumeAttribute {sender: me}, username, session_id, region_name, volume_id, auto_enable_IO
		ebs_model.once "EC2_EBS_MODIFY_VOL_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.EnableVolumeIO
		ebs_model.EnableVolumeIO {sender: me}, username, session_id, region_name, volume_id
		ebs_model.once "EC2_EBS_ENABLE_VOL_I_O_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.CreateSnapshot
		ebs_model.CreateSnapshot {sender: me}, username, session_id, region_name, volume_id, description
		ebs_model.once "EC2_EBS_CREATE_SS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.DeleteSnapshot
		ebs_model.DeleteSnapshot {sender: me}, username, session_id, region_name, snapshot_id
		ebs_model.once "EC2_EBS_DELETE_SS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.ModifySnapshotAttribute
		ebs_model.ModifySnapshotAttribute {sender: me}, username, session_id, region_name, snapshot_id, user_ids, group_names
		ebs_model.once "EC2_EBS_MODIFY_SS_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.ResetSnapshotAttribute
		ebs_model.ResetSnapshotAttribute {sender: me}, username, session_id, region_name, snapshot_id, attribute_name
		ebs_model.once "EC2_EBS_RESET_SS_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.DescribeSnapshots
		ebs_model.DescribeSnapshots {sender: me}, username, session_id, region_name, snapshot_ids, owners, restorable_by, filters
		ebs_model.once "EC2_EBS_DESC_SSS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ebs.DescribeSnapshotAttribute
		ebs_model.DescribeSnapshotAttribute {sender: me}, username, session_id, region_name, snapshot_id, attribute_name
		ebs_model.once "EC2_EBS_DESC_SS_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## EC2 ##########

		#ec2.CreateTags
		ec2_model.CreateTags {sender: me}, username, session_id, region_name, resource_ids, tags
		ec2_model.once "EC2_EC2_CREATE_TAGS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ec2.DeleteTags
		ec2_model.DeleteTags {sender: me}, username, session_id, region_name, resource_ids, tags
		ec2_model.once "EC2_EC2_DELETE_TAGS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ec2.DescribeTags
		ec2_model.DescribeTags {sender: me}, username, session_id, region_name, filters
		ec2_model.once "EC2_EC2_DESC_TAGS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ec2.DescribeRegions
		ec2_model.DescribeRegions {sender: me}, username, session_id, region_names, filters
		ec2_model.once "EC2_EC2_DESC_REGIONS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#ec2.DescribeAvailabilityZones
		ec2_model.DescribeAvailabilityZones {sender: me}, username, session_id, region_name, zone_names, filters
		ec2_model.once "EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## EIP ##########

		#eip.AllocateAddress
		eip_model.AllocateAddress {sender: me}, username, session_id, region_name, domain
		eip_model.once "EC2_EIP_ALLOCATE_ADDR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#eip.ReleaseAddress
		eip_model.ReleaseAddress {sender: me}, username, session_id, region_name, ip, allocation_id
		eip_model.once "EC2_EIP_RELEASE_ADDR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#eip.AssociateAddress
		eip_model.AssociateAddress {sender: me}, username
		eip_model.once "EC2_EIP_ASSOCIATE_ADDR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#eip.DisassociateAddress
		eip_model.DisassociateAddress {sender: me}, username, session_id, region_name, ip, association_id
		eip_model.once "EC2_EIP_DISASSOCIATE_ADDR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#eip.DescribeAddresses
		eip_model.DescribeAddresses {sender: me}, username, session_id, region_name, ips, allocation_ids, filters
		eip_model.once "EC2_EIP_DESC_ADDRES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## Instance ##########

		#instance.RunInstances
		instance_model.RunInstances {sender: me}, username, session_id
		instance_model.once "EC2_INS_RUN_INSTANCES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.StartInstances
		instance_model.StartInstances {sender: me}, username, session_id, region_name, instance_ids
		instance_model.once "EC2_INS_START_INSTANCES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.StopInstances
		instance_model.StopInstances {sender: me}, username, session_id, region_name, instance_ids, force
		instance_model.once "EC2_INS_STOP_INSTANCES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.RebootInstances
		instance_model.RebootInstances {sender: me}, username, session_id, region_name, instance_ids
		instance_model.once "EC2_INS_REBOOT_INSTANCES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.TerminateInstances
		instance_model.TerminateInstances {sender: me}, username, session_id, region_name, instance_ids
		instance_model.once "EC2_INS_TERMINATE_INSTANCES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.MonitorInstances
		instance_model.MonitorInstances {sender: me}, username, session_id, region_name, instance_ids
		instance_model.once "EC2_INS_MONITOR_INSTANCES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.UnmonitorInstances
		instance_model.UnmonitorInstances {sender: me}, username, session_id, region_name, instance_ids
		instance_model.once "EC2_INS_UNMONITOR_INSTANCES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.BundleInstance
		instance_model.BundleInstance {sender: me}, username, session_id, region_name, instance_id, s3_bucket
		instance_model.once "EC2_INS_BUNDLE_INSTANCE_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.CancelBundleTask
		instance_model.CancelBundleTask {sender: me}, username, session_id, region_name, bundle_id
		instance_model.once "EC2_INS_CANCEL_BUNDLE_TASK_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.ModifyInstanceAttribute
		instance_model.ModifyInstanceAttribute {sender: me}, username, session_id
		instance_model.once "EC2_INS_MODIFY_INSTANCE_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.ResetInstanceAttribute
		instance_model.ResetInstanceAttribute {sender: me}, username, session_id, region_name, instance_id, attribute_name
		instance_model.once "EC2_INS_RESET_INSTANCE_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.ConfirmProductInstance
		instance_model.ConfirmProductInstance {sender: me}, username, session_id, region_name, instance_id, product_code
		instance_model.once "EC2_INS_CONFIRM_PRODUCT_INSTANCE_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.DescribeInstances
		instance_model.DescribeInstances {sender: me}, username, session_id, region_name, instance_ids, filters
		instance_model.once "EC2_INS_DESC_INSTANCES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.DescribeInstanceStatus
		instance_model.DescribeInstanceStatus {sender: me}, username, session_id, region_name, instance_ids, include_all_instances, max_results, next_token
		instance_model.once "EC2_INS_DESC_INSTANCE_STATUS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.DescribeBundleTasks
		instance_model.DescribeBundleTasks {sender: me}, username, session_id, region_name, bundle_ids, filters
		instance_model.once "EC2_INS_DESC_BUNDLE_TASKS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.DescribeInstanceAttribute
		instance_model.DescribeInstanceAttribute {sender: me}, username, session_id, region_name, instance_id, attribute_name
		instance_model.once "EC2_INS_DESC_INSTANCE_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.GetConsoleOutput
		instance_model.GetConsoleOutput {sender: me}, username, session_id, region_name, instance_id
		instance_model.once "EC2_INS_GET_CONSOLE_OUTPUT_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#instance.GetPasswordData
		instance_model.GetPasswordData {sender: me}, username, session_id, region_name, instance_id, key_data
		instance_model.once "EC2_INS_GET_PWD_DATA_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## KeyPair ##########

		#keypair.CreateKeyPair
		keypair_model.CreateKeyPair {sender: me}, username, session_id, region_name, key_name
		keypair_model.once "EC2_KP_CREATE_KEY_PAIR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#keypair.DeleteKeyPair
		keypair_model.DeleteKeyPair {sender: me}, username, session_id, region_name, key_name
		keypair_model.once "EC2_KP_DELETE_KEY_PAIR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#keypair.ImportKeyPair
		keypair_model.ImportKeyPair {sender: me}, username, session_id, region_name, key_name, key_data
		keypair_model.once "EC2_KP_IMPORT_KEY_PAIR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#keypair.DescribeKeyPairs
		keypair_model.DescribeKeyPairs {sender: me}, username, session_id, region_name, key_names, filters
		keypair_model.once "EC2_KP_DESC_KEY_PAIRS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#keypair.upload
		keypair_model.upload {sender: me}, username, session_id, region_name, key_name, key_data
		keypair_model.once "EC2_KPUPLOAD_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#keypair.download
		keypair_model.download {sender: me}, username, session_id, region_name, key_name
		keypair_model.once "EC2_KPDOWNLOAD_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#keypair.remove
		keypair_model.remove {sender: me}, username, session_id, region_name, key_name
		keypair_model.once "EC2_KPREMOVE_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#keypair.list
		keypair_model.list {sender: me}, username, session_id, region_name
		keypair_model.once "EC2_KPLST_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## PlacementGroup ##########

		#placementgroup.CreatePlacementGroup
		placementgroup_model.CreatePlacementGroup {sender: me}, username, session_id, region_name, group_name, strategy
		placementgroup_model.once "EC2_PG_CREATE_PLA_GRP_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#placementgroup.DeletePlacementGroup
		placementgroup_model.DeletePlacementGroup {sender: me}, username, session_id, region_name, group_name
		placementgroup_model.once "EC2_PG_DELETE_PLA_GRP_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#placementgroup.DescribePlacementGroups
		placementgroup_model.DescribePlacementGroups {sender: me}, username, session_id, region_name, group_names, filters
		placementgroup_model.once "EC2_PG_DESC_PLA_GRPS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## SecurityGroup ##########

		#securitygroup.CreateSecurityGroup
		securitygroup_model.CreateSecurityGroup {sender: me}, username, session_id, region_name, group_name, group_desc, vpc_id
		securitygroup_model.once "EC2_SG_CREATE_SG_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#securitygroup.DeleteSecurityGroup
		securitygroup_model.DeleteSecurityGroup {sender: me}, username, session_id, region_name, group_name, group_id
		securitygroup_model.once "EC2_SG_DELETE_SG_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#securitygroup.AuthorizeSecurityGroupIngress
		securitygroup_model.AuthorizeSecurityGroupIngress {sender: me}, username, session_id
		securitygroup_model.once "EC2_SG_AUTH_SG_INGRESS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#securitygroup.RevokeSecurityGroupIngress
		securitygroup_model.RevokeSecurityGroupIngress {sender: me}, username, session_id
		securitygroup_model.once "EC2_SG_REVOKE_SG_INGRESS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#securitygroup.DescribeSecurityGroups
		securitygroup_model.DescribeSecurityGroups {sender: me}, username, session_id, region_name, group_names, group_ids, filters
		securitygroup_model.once "EC2_SG_DESC_SGS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ELB ##########

		#elb.DescribeInstanceHealth
		elb_model.DescribeInstanceHealth {sender: me}, username, session_id, region_name, elb_name, instance_ids
		elb_model.once "ELB__DESC_INS_HLT_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#elb.DescribeLoadBalancerPolicies
		elb_model.DescribeLoadBalancerPolicies {sender: me}, username, session_id, region_name, elb_name, policy_names
		elb_model.once "ELB__DESC_LB_PCYS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#elb.DescribeLoadBalancerPolicyTypes
		elb_model.DescribeLoadBalancerPolicyTypes {sender: me}, username, session_id, region_name, policy_type_names
		elb_model.once "ELB__DESC_LB_PCY_TYPS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#elb.DescribeLoadBalancers
		elb_model.DescribeLoadBalancers {sender: me}, username, session_id, region_name, elb_names, marker
		elb_model.once "ELB__DESC_LBS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## IAM ##########

		#iam.GetServerCertificate
		iam_model.GetServerCertificate {sender: me}, username, session_id, region_name, servercer_name
		iam_model.once "IAM__GET_SERVER_CERTIFICATE_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#iam.ListServerCertificates
		iam_model.ListServerCertificates {sender: me}, username, session_id, region_name, marker, max_items, path_prefix
		iam_model.once "IAM__LST_SERVER_CERTIFICATES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## OpsWorks ##########

		#opsworks.DescribeApps
		opsworks_model.DescribeApps {sender: me}, username, session_id, region_name, app_ids, stack_id
		opsworks_model.once "OPSWORKS__DESC_APPS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribeStacks
		opsworks_model.DescribeStacks {sender: me}, username, session_id, region_name, stack_ids
		opsworks_model.once "OPSWORKS__DESC_STACKS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribeCommands
		opsworks_model.DescribeCommands {sender: me}, username, session_id, region_name, command_ids, deployment_id, instance_id
		opsworks_model.once "OPSWORKS__DESC_COMMANDS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribeDeployments
		opsworks_model.DescribeDeployments {sender: me}, username, session_id, region_name, app_id, deployment_ids, stack_id
		opsworks_model.once "OPSWORKS__DESC_DEPLOYMENTS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribeElasticIps
		opsworks_model.DescribeElasticIps {sender: me}, username, session_id, region_name, instance_id, ips
		opsworks_model.once "OPSWORKS__DESC_ELASTIC_IPS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribeInstances
		opsworks_model.DescribeInstances {sender: me}, username, session_id, region_name, app_id, instance_ids, layer_id, stack_id
		opsworks_model.once "OPSWORKS__DESC_INSS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribeLayers
		opsworks_model.DescribeLayers {sender: me}, username, session_id, region_name, stack_id, layer_ids
		opsworks_model.once "OPSWORKS__DESC_LAYERS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribeLoadBasedAutoScaling
		opsworks_model.DescribeLoadBasedAutoScaling {sender: me}, username, session_id, region_name, layer_ids
		opsworks_model.once "OPSWORKS__DESC_LOAD_BASED_ASL_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribePermissions
		opsworks_model.DescribePermissions {sender: me}, username, session_id, region_name, iam_user_arn, stack_id
		opsworks_model.once "OPSWORKS__DESC_PERMISSIONS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribeRaidArrays
		opsworks_model.DescribeRaidArrays {sender: me}, username, session_id, region_name, instance_id, raid_array_ids
		opsworks_model.once "OPSWORKS__DESC_RAID_ARRAYS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribeServiceErrors
		opsworks_model.DescribeServiceErrors {sender: me}, username, session_id, region_name, instance_id, service_error_ids, stack_id
		opsworks_model.once "OPSWORKS__DESC_SERVICE_ERRORS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribeTimeBasedAutoScaling
		opsworks_model.DescribeTimeBasedAutoScaling {sender: me}, username, session_id, region_name, instance_ids
		opsworks_model.once "OPSWORKS__DESC_TIME_BASED_ASL_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribeUserProfiles
		opsworks_model.DescribeUserProfiles {sender: me}, username, session_id, region_name, iam_user_arns
		opsworks_model.once "OPSWORKS__DESC_USER_PROFILES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#opsworks.DescribeVolumes
		opsworks_model.DescribeVolumes {sender: me}, username, session_id, region_name, instance_id, raid_array_id, volume_ids
		opsworks_model.once "OPSWORKS__DESC_VOLS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## Instance ##########

		#instance.DescribeDBInstances
		instance_model.DescribeDBInstances {sender: me}, username, session_id, region_name, instance_id, marker, max_records
		instance_model.once "RDS_INS_DESC_DB_INSTANCES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## OptionGroup ##########

		#optiongroup.DescribeOptionGroupOptions
		optiongroup_model.DescribeOptionGroupOptions {sender: me}, username, session_id
		optiongroup_model.once "RDS_OG_DESC_OPT_GRP_OPTIONS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#optiongroup.DescribeOptionGroups
		optiongroup_model.DescribeOptionGroups {sender: me}, username, session_id
		optiongroup_model.once "RDS_OG_DESC_OPT_GRPS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ParameterGroup ##########

		#parametergroup.DescribeDBParameterGroups
		parametergroup_model.DescribeDBParameterGroups {sender: me}, username, session_id, region_name, pg_name, marker, max_records
		parametergroup_model.once "RDS_PG_DESC_DB_PARAM_GRPS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#parametergroup.DescribeDBParameters
		parametergroup_model.DescribeDBParameters {sender: me}, username, session_id, region_name, pg_name, source, marker, max_records
		parametergroup_model.once "RDS_PG_DESC_DB_PARAMS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## RDS ##########

		#rds.DescribeDBEngineVersions
		rds_model.DescribeDBEngineVersions {sender: me}, username
		rds_model.once "RDS_RDS_DESC_DB_ENG_VERS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#rds.DescribeOrderableDBInstanceOptions
		rds_model.DescribeOrderableDBInstanceOptions {sender: me}, username
		rds_model.once "RDS_RDS_DESC_ORD_DB_INS_OPTS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#rds.DescribeEngineDefaultParameters
		rds_model.DescribeEngineDefaultParameters {sender: me}, username, session_id, region_name, pg_family, marker, max_records
		rds_model.once "RDS_RDS_DESC_ENG_DFT_PARAMS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#rds.DescribeEvents
		rds_model.DescribeEvents {sender: me}, username, session_id
		rds_model.once "RDS_RDS_DESC_EVENTS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ReservedInstance ##########

		#reservedinstance.DescribeReservedDBInstances
		reservedinstance_model.DescribeReservedDBInstances {sender: me}, username, session_id
		reservedinstance_model.once "RDS_RSVDINS_DESC_RESERVED_DB_INSTANCES_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#reservedinstance.DescribeReservedDBInstancesOfferings
		reservedinstance_model.DescribeReservedDBInstancesOfferings {sender: me}, username, session_id
		reservedinstance_model.once "RDS_RSVDINS_DESC_RESERVED_DB_INSTANCES_OFFERINGS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## SecurityGroup ##########

		#securitygroup.DescribeDBSecurityGroups
		securitygroup_model.DescribeDBSecurityGroups {sender: me}, username, session_id, region_name, sg_name, marker, max_records
		securitygroup_model.once "RDS_SG_DESC_DB_SGS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## Snapshot ##########

		#snapshot.DescribeDBSnapshots
		snapshot_model.DescribeDBSnapshots {sender: me}, username, session_id
		snapshot_model.once "RDS_SS_DESC_DB_SNAPSHOTS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## SubnetGroup ##########

		#subnetgroup.DescribeDBSubnetGroups
		subnetgroup_model.DescribeDBSubnetGroups {sender: me}, username, session_id, region_name, sg_name, marker, max_records
		subnetgroup_model.once "RDS_SNTG_DESC_DB_SNET_GRPS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## SDB ##########

		#sdb.DomainMetadata
		sdb_model.DomainMetadata {sender: me}, username, session_id, region_name, doamin_name
		sdb_model.once "SDB__DOMAIN_MDATA_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#sdb.GetAttributes
		sdb_model.GetAttributes {sender: me}, username, session_id, region_name, domain_name, item_name, attribute_name, consistent_read
		sdb_model.once "SDB__GET_ATTRS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#sdb.ListDomains
		sdb_model.ListDomains {sender: me}, username, session_id, region_name, max_domains, next_token
		sdb_model.once "SDB__LST_DOMAINS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ACL ##########

		#acl.DescribeNetworkAcls
		acl_model.DescribeNetworkAcls {sender: me}, username, session_id, region_name, acl_ids, filters
		acl_model.once "VPC_ACL_DESC_NET_ACLS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## CustomerGateway ##########

		#customergateway.DescribeCustomerGateways
		customergateway_model.DescribeCustomerGateways {sender: me}, username, session_id, region_name, gw_ids, filters
		customergateway_model.once "VPC_CGW_DESC_CUST_GWS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## DHCP ##########

		#dhcp.DescribeDhcpOptions
		dhcp_model.DescribeDhcpOptions {sender: me}, username, session_id, region_name, dhcp_ids, filters
		dhcp_model.once "VPC_DHCP_DESC_DHCP_OPTS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ENI ##########

		#eni.DescribeNetworkInterfaces
		eni_model.DescribeNetworkInterfaces {sender: me}, username, session_id, region_name, eni_ids, filters
		eni_model.once "VPC_ENI_DESC_NET_IFS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#eni.DescribeNetworkInterfaceAttribute
		eni_model.DescribeNetworkInterfaceAttribute {sender: me}, username, session_id, region_name, eni_id, attribute
		eni_model.once "VPC_ENI_DESC_NET_IF_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## InternetGateway ##########

		#internetgateway.DescribeInternetGateways
		internetgateway_model.DescribeInternetGateways {sender: me}, username, session_id, region_name, gw_ids, filters
		internetgateway_model.once "VPC_IGW_DESC_INET_GWS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## RouteTable ##########

		#routetable.DescribeRouteTables
		routetable_model.DescribeRouteTables {sender: me}, username, session_id, region_name, rt_ids, filters
		routetable_model.once "VPC_RT_DESC_RT_TBLS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## Subnet ##########

		#subnet.DescribeSubnets
		subnet_model.DescribeSubnets {sender: me}, username, session_id, region_name, subnet_ids, filters
		subnet_model.once "VPC_SNET_DESC_SUBNETS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## VPC ##########

		#vpc.DescribeVpcs
		vpc_model.DescribeVpcs {sender: me}, username, session_id, region_name, vpc_ids, filters
		vpc_model.once "VPC_VPC_DESC_VPCS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#vpc.DescribeAccountAttributes
		vpc_model.DescribeAccountAttributes {sender: me}, username, session_id, region_name, attribute_name
		vpc_model.once "VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result


		#vpc.DescribeVpcAttribute
		vpc_model.DescribeVpcAttribute {sender: me}, username, session_id, region_name, vpc_id, attribute
		vpc_model.once "VPC_VPC_DESC_VPC_ATTR_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## VPNGateway ##########

		#vpngateway.DescribeVpnGateways
		vpngateway_model.DescribeVpnGateways {sender: me}, username, session_id, region_name, gw_ids, filters
		vpngateway_model.once "VPC_VGW_DESC_VPN_GWS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## VPN ##########

		#vpn.DescribeVpnConnections
		vpn_model.DescribeVpnConnections {sender: me}, username, session_id, region_name, vpn_ids, filters
		vpn_model.once "VPC_VPN_DESC_VPN_CONNS_RETURN", ( aws_result ) ->
			resolveResult request_time, current_service, current_resource, current_api, aws_result



		null

	#public object
	ready : () ->
		$( '#login_form' ).submit( login )
		$( '#request_form' ).submit( request )
		window.init()


