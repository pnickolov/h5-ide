#############################
#  View Mode for design/property/instance (app)
#############################

define [ '../base/model' ], ( PropertyModel ) ->

	AmiAppEditModel = PropertyModel.extend {

		init : ( uid ) ->
			@set 'uid', uid
			@getInstanceType()

		getInstanceType : () ->

			uid = this.get 'uid'
			component = MC.canvas_data.component[ uid ]

			tenacy = component.resource.Placement.Tenancy isnt 'dedicated'

			this.set 'ebs_optimized', "" + component.resource.EbsOptimized is "true"
			this.set 'monitoring',    component.resource.Monitoring is 'enabled'
			this.set 'tenacy',        tenacy

			this.set 'force_tenacy', false
			for comp_uid, comp of MC.canvas_data.layout.component.group
				if comp.type is 'AWS.VPC.VPC'
					vpc = MC.canvas_data.component[ comp_uid ]
					if vpc.resource.InstanceTenancy is "dedicated"
						this.set 'force_tenacy', true
					break

			if MC.data.dict_ami and MC.data.dict_ami[ component.resource.ImageId ]
				ami_info = MC.data.dict_ami[ component.resource.ImageId ]
			else
				ami_info = MC.canvas_data.layout.component.node[ uid ]

			current_instance_type = component.resource.InstanceType


			if this._getInstanceType( ami_info )
				view_instance_type = _.map this._getInstanceType( ami_info ), ( value )->

					main     : constant.INSTANCE_TYPE[value][0]
					ecu      : constant.INSTANCE_TYPE[value][1]
					core     : constant.INSTANCE_TYPE[value][2]
					mem      : constant.INSTANCE_TYPE[value][3]
					name     : value
					selected : current_instance_type is value
					hide     : not tenacy and value is "t1.micro"
			else
				view_instance_type = []
				view_instance_type[0] =
					main     : ''
					ecu      : ''
					core     : ''
					mem      : ''
					name     : ''
					selected : false
					hide     : true

			this.set 'instance_type', view_instance_type
			this.set 'can_set_ebs',   EbsMap.hasOwnProperty current_instance_type

			null

		getEni : () ->

			uid = this.get 'uid'
			instanceUID = uid

			defaultVPCId = MC.aws.aws.checkDefaultVPC()
			if !MC.canvas_data.component[uid].resource.SubnetId and !defaultVPCId
				return

			eni_detail = {}

			eni_detail.eni_ips = []

			eni_count = 0

			subnetCIDR = ''
			if defaultVPCId
				subnetObj = MC.aws.vpc.getSubnetForDefaultVPC(instanceUID)
				subnetCIDR = subnetObj.cidrBlock
			else
				subnetUID = MC.canvas_data.component[uid].resource.SubnetId.split('.')[0][1...]
				subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

			prefixSuffixAry = MC.aws.subnet.genCIDRPrefixSuffix(subnetCIDR)

			_.map MC.canvas_data.component, ( val, key ) ->

				if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

					eni_detail.description = val.resource.Description

					if val.resource.AssociatePublicIpAddress

						eni_detail.asso_public_ip = val.resource.AssociatePublicIpAddress
					else
						eni_detail.asso_public_ip = false

					eni_detail.sourceCheck = true if val.resource.SourceDestCheck == 'true' or val.resource.SourceDestCheck == true

					eni_detail.eni_ips = $.extend true, {}, val.resource.PrivateIpAddressSet

					$.each eni_detail.eni_ips, ( idx, ip_detail) ->

						ip_ref = '@' + val.uid + '.resource.PrivateIpAddressSet.' + idx + '.PrivateIpAddress'

						ip_detail.prefix = prefixSuffixAry[0]

						if ip_detail.AutoAssign is true or ip_detail.AutoAssign is 'true'
							ip_detail.suffix = prefixSuffixAry[1]
						else
							# subnetComp = MC.aws.eni.getSubnetComp(uid)
							# subnetCIDR = subnetComp.resource.CidrBlock
							ipAddress = ip_detail.PrivateIpAddress
							fixPrefixSuffixAry = MC.aws.eni.getENIDivIPAry(subnetCIDR, ipAddress)
							ip_detail.suffix = fixPrefixSuffixAry[1]

						$.each MC.canvas_data.component, ( comp_uid, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.PrivateIpAddress == ip_ref

								ip_detail.has_eip = true

								return false
						eni_count += 1
						null
				else if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid

					eni_count += 1

				null

			if eni_count > 1

				eni_detail.multi_enis = true

			else
				eni_detail.multi_enis = false

			this.set 'eni_display', eni_detail
	}

	new AmiAppEditModel()
