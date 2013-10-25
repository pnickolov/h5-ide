#############################
#  View Mode for design/property/instance (app)
#############################

define [ '../base/model',
	'./model',
	'constant',
	'i18n!nls/lang.js'
], ( PropertyModel, stack_model, constant, lang ) ->

	AmiAppEditModel = PropertyModel.extend {

		init : ( uid ) ->

			myInstanceComponent = MC.canvas_data.component[ uid ]

			# Find out AMI
			ami_id = myInstanceComponent.resource.ImageId
			ami    = MC.data.dict_ami[ ami_id ] || MC.canvas_data.layout.component.node[ uid ]

			if ami
				@set 'ami', {
					id   : ami_id
					name : ami.name
					icon : "#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}.png"
				}
			else
				notification 'warning', sprintf lang.ide.PROP_MSG_ERR_AMI_NOT_FOUND, ami_id

			# Find out Instance Type
			tenancy = myInstanceComponent.resource.Placement.Tenancy isnt 'dedicated'
			instance_type_list = @getInstanceTypeList( ami, tenancy, myInstanceComponent.resource.InstanceType )

			# If the ami is linked to route table, cannot set server group
			for uid, comp of MC.canvas_data.component
				if comp.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
					continue

				if comp.resource.RouteSet.join(",").indexOf( uid ) isnt -1
					@set 'number_disable', true
					break

			@set 'instance_type', instance_type_list

			@set 'uid',    uid
			@set 'number', myInstanceComponent.number
			@set 'name',   myInstanceComponent.serverGroupName
			null

		getInstanceTypeList : ( ami, tenancy, current_instance_type ) ->
			list = MC.aws.ami.getInstanceType( ami )

			if list.length
				list =_.map list, ( value ) ->
					main     : constant.INSTANCE_TYPE[value][0]
					ecu      : constant.INSTANCE_TYPE[value][1]
					core     : constant.INSTANCE_TYPE[value][2]
					mem      : constant.INSTANCE_TYPE[value][3]
					name     : value
					selected : current_instance_type is value
					hide     : not tenancy and value is "t1.micro"
				return list
			else
				return []

		getSGList        : stack_model.getSGList
		assignSGToComp   : stack_model.assignSGToComp
		unAssignSGToComp : stack_model.unAssignSGToComp
	}

	new AmiAppEditModel()
