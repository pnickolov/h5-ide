#############################
#  View Mode for dashboard(region)
#############################

define [ 'backbone', 'jquery', 'underscore', 'event', 'aws_model', 'constant' ], (Backbone, $, _, ide_event, aws_model, constant) ->

    current_region = null
    resource_source = null

    #private
    RegionModel = Backbone.Model.extend {

        defaults :
            'cur_app_list'          : null
            'cur_stack_list'        : null
            'resourse_list'         : null


        initialize : ->
            # me = this

            # aws_model.on 'AWS_RESOURCE_RETURN', ( result ) ->

            #     resource_source = result.resolved_data[current_region]

            #     me.setResource resource_source

            #     null

        resultListListener : ->
            me = this

            ide_event.onListen 'RESULT_APP_LIST', ( result ) ->

                # get current region's apps
                me.getItemList(result)

                null

            ide_event.onListen 'RESULT_STACK_LIST', ( result ) ->

                # get current region's stacks
                me.getItemList(result)

                null
            null

        # get all app/stack
        getItemList : ( items ) ->

            items[current_region]

        # parse a single app/stack

        setResource : ( resources ) ->

            lists = {}

            elb = resources.DescribeLoadBalancers.LoadBalancerDescriptions

            if $.isEmptyObject elb then lists.ELB = 0 else if  elb.member.constructor == Array then lists.ELB = elb.member.length else lists.ELB = 1



            console.error lists

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

    }

    model = new RegionModel()

    return model