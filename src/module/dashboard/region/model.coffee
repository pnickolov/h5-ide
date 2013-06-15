#############################
#  View Mode for dashboard(region)
#############################

define [ 'backbone', 'jquery', 'underscore', 'aws_model', 'vpc_model',  'constant' ], (Backbone, $, _, aws_model, vpc_model, constant) ->

    current_region  = null
    resource_source = null
    vpc_attrs_value = null
    unmanaged_list  = null

    update_timestamp = 0

    #private
    RegionModel = Backbone.Model.extend {

        defaults :
            'resourse_list'         : null
            'vpc_attrs'             : null
            'unmanaged_list'        : null

        initialize : ->
            me = this

            aws_model.on 'AWS_RESOURCE_RETURN', ( result ) ->

                console.log 'AWS_RESOURCE_RETURN'

                resource_source = result.resolved_data[current_region]

                me.setResource resource_source
                
                null


            null

        #temp
        temp : ->
            me = this
            null

<<<<<<< HEAD
        #unmanaged_list
        updateUnmanagedList : ()->


            me = this

            time_stamp = new Date().getTime() / 1000
            unmanaged_list = {}
            unmanaged_list.time_stamp = time_stamp

            console.log 'unmanaged_list'

            me.set 'unmanaged_list', unmanaged_list

            null

        #vpc_attrs
        describeRegionAccountAttributesService : ( region )->

            me = this

            current_region = region

            vpc_model.DescribeAccountAttributes { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  ["supported-platforms"]

            vpc_model.on 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', ( result ) ->

                console.log 'region_VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'

                regionAttrSet = result.resolved_data.accountAttributeSet.item.attributeValueSet.item
                if $.type(regionAttrSet) == "array"
                    vpc_attrs_value = { 'classic' : 'Classic', 'vpc' : 'VPC' }
                else
                    vpc_attrs_value = { 'vpc' : 'VPC' }

                me.set 'vpc_attrs', vpc_attrs_value

                null

            null
=======
        setResource : ( resources ) ->

            lists = {}

            elb = resources.DescribeLoadBalancers.LoadBalancerDescriptions

            if $.isEmptyObject elb then lists.ELB = 0 else if  elb.member.constructor == Array then lists.ELB = elb.member.length else lists.ELB = 1

                
            
            console.error lists
>>>>>>> origin/feature/dashboard-region-aws-resource

        describeAWSResourcesService : ( region )->

            me = this

            current_region = region

            resources = [
                constant.AWS_RESOURCE.INSTANCE
                constant.AWS_RESOURCE.EIP
                constant.AWS_RESOURCE.VOLUME
                constant.AWS_RESOURCE.VPC
                constant.AWS_RESOURCE.VPN
                constant.AWS_RESOURCE.ELB
            ]

            aws_model.resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region,  resources

            me.updateUnmanagedList()

    }

    model = new RegionModel()

    return model