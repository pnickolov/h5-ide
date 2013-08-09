define [ 'MC', 'constant' ], ( MC, constant ) ->

	#private
	getNewName = (compType) ->

		new_name 	= ""
		name_prefix = ""
		max_num 	= 0

		switch compType

			when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
				name_prefix = "host"

			when constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup
				name_prefix = "sg-"

			when constant.AWS_RESOURCE_TYPE.AWS_ELB
				name_prefix = "load-balancer-"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC
				name_prefix = "vpc"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
				name_prefix = "subnet"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
				name_prefix = "RT-"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway
				name_prefix = "customer-gateway-"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
				name_prefix = "eni"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
				name_prefix = "acl-"


		_.each MC.canvas_data.component, (compObj) ->

			if compObj.type is compType

				new_name = compObj.name

				if new_name.slice(0, name_prefix.length) is name_prefix

					currentNum = Number(new_name.slice(name_prefix.length))

					if currentNum > max_num

						max_num = currentNum
			null

		max_num++

		#return new name
		name_prefix + max_num

	#public
	getNewName : getNewName
