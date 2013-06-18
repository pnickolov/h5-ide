#############################
#  View Mode for dashboard(region)
#############################

define [ 'MC', 'backbone', 'jquery', 'underscore', 'event', 'aws_model', 'constant' ], (MC, Backbone, $, _, ide_event, aws_model, constant) ->

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

        # get current region's app/stack list
        getItemList : ( app_list, stack_list ) ->
            me = this

            cur_app_list = []
            _.map app_list, (value) ->
                item = me.parseItem(value, 'app')
                if item
                    cur_app_list.push item

                    null

            cur_stack_list = []
            _.map stack_list, (value) ->
                item = me.parseItem(value, 'stack')
                if item
                    cur_stack_list.push item

            if cur_app_list
                me.set 'cur_app_list', cur_app_list
            if cur_stack_list
                me.set 'cur_stack_list', cur_stack_list

        parseItem : (item, flag) ->
            id          = item.id
            name        = item.name
            create_time = item.time_create
            isrunning   = true
            ispending   = false

            # check state
            if item.state == 'Running'
                isrunning = true
            else if item.state == 'Stopped'
                isrunning = false
            else
                ispending = true

            if flag == 'app'
                date = new Date()
                date.setTime(item.time_create*1000)
                start_time  = "GMT " + MC.dateFormat(date, "hh:mm yyyy-MM-dd")
                if not isrunning
                    date.setTime(item.time_update*1000)
                    stop_time = "GMT " + MC.dateFormat(date, "hh:mm yyyy-MM-dd")

                # bubble data
                bubble_data = '{"status":' + if ispending then '"pending"' else if isrunning then '"play"' else '"stop"'
                bubble_data += ',"title":"' + name + '","start-time":"' + start_time + '","end-time":"'
                if not isrunning
                    bubble_data += if stop_time then stop_time
                bubble_data += '","cost":"$0/month"}'

            return { 'id' : id, 'name' : name, 'create_time':create_time, 'isrunning' : isrunning, 'bubble_data' : bubble_data}

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