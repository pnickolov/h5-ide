#############################
#  View Mode for design/property/instance (app)
#############################

define [ '../base/model',
	'constant',
	'i18n!nls/lang.js'
], ( PropertyModel, constant, lang ) ->

	EbsMap =
		"m1.large"   : true
		"m1.xlarge"  : true
		"m2.2xlarge" : true
		"m2.4xlarge" : true
		"m3.xlarge"  : true
		"m3.2xlarge" : true
		"c1.xlarge"  : true

	AmiAppEditModel = PropertyModel.extend {

		init : ( uid ) ->
			@set 'id', uid
			@getInstanceType()


			instance_id = MC.canvas_data.component[uid].resource.InstanceId

			myInstanceComponent = MC.canvas_data.component[ instance_id ]

			# The instance_id might be component uid or aws id
			if myInstanceComponent
				instance_id = myInstanceComponent.resource.InstanceId

			app_data = MC.data.resource_list[ MC.canvas_data.region ]

			if app_data[ instance_id ]

				instance = $.extend true, {}, app_data[ instance_id ]
				instance.name = if myInstanceComponent then myInstanceComponent.name else instance_id

				# Possible value : running, stopped, pending...
				instance.isRunning = instance.instanceState.name == "running"
				instance.isPending = instance.instanceState.name == "pending"
				instance.instanceState.name = MC.capitalize instance.instanceState.name
				instance.blockDevice = ""
				if instance.blockDeviceMapping && instance.blockDeviceMapping.item
					deviceName = []
					for i in instance.blockDeviceMapping.item
						deviceName.push i.deviceName

					instance.blockDevice = deviceName.join ", "

				# Eni Data
				instance.eni = this.getEniData instance

				this.set instance

			else

				console.log 'Can not found data for this instance: ' + instance_id

			null

		getInstanceType : () ->

			uid = this.get 'id'
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

			uid = this.get 'id'
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

		getEniData : ( instance_data ) ->

            if not instance_data.networkInterfaceSet
                return null

            for i in instance_data.networkInterfaceSet.item
                if i.attachment.deviceIndex == "0"
                    id = i.networkInterfaceId
                    data = i
                    break

            TYPE_ENI = constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

            if not id
                return null

            for key, value of MC.canvas_data.component
                if value.type == TYPE_ENI && value.resource.NetworkInterfaceId == id
                    component = value
                    break

            appData = MC.data.resource_list[ MC.canvas_data.region ]

            if not appData[id]
                # Use data inside networkInterfaceSet
                data = $.extend true, {}, data
            else
                # Use data inside appData
                data = $.extend true, {}, appData[ id ]

            data.name = if component then component.name else id
            if data.status == "in-use"
                data.isInUse = true

            data.sourceDestCheck = if data.sourceDestCheck is "true" then "enabled" else "disabled"

            for i in data.privateIpAddressesSet.item
                i.primary = i.primary == true

            data

		_getInstanceType : ( ami ) ->
			instance_type = MC.data.instance_type[MC.canvas_data.region]
			if ami.virtualizationType == 'hvm'
				instance_type = instance_type.windows
			else
				instance_type = instance_type.linux
			if ami.rootDeviceType == 'ebs'
				instance_type = instance_type.ebs
			else
				instance_type = instance_type['instance store']
			if ami.architecture == 'x86_64'
				instance_type = instance_type["64"]
			else
				instance_type = instance_type["32"]

			if !ami.virtualizationType
				ami.virtualizationType = 'paravirtual'

			instance_type = instance_type[ami.virtualizationType]

			instance_type
	}

	new AmiAppEditModel()
