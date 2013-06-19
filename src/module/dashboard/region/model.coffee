#############################
#  View Mode for dashboard(region)
#############################

define [ 'MC', 'backbone', 'jquery', 'underscore', 'event', 'aws_model', 'constant', 'app_model', 'stack_model' ], (MC, Backbone, $, _, ide_event, aws_model, constant, app_model, stack_model) ->

    current_region = null
    resource_source = null

    #private
    RegionModel = Backbone.Model.extend {

        defaults :
            'cur_app_list'          : []
            'cur_stack_list'        : []
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
                getItemList('app', result[current_region])

                null

            ide_event.onListen 'RESULT_STACK_LIST', ( result ) ->

                # get current region's stacks
                getItemList('stack', result[current_region])

                null
            null

        # get current region's app/stack list
        getItemList : ( flag, item_list ) ->
            me = this

            cur_item_list = []
            _.map item_list, (value) ->
                item = me.parseItem(value, flag)
                if item
                    cur_item_list.push item

                    null

            if cur_item_list
                if flag == 'app'
                    #difference
                    if _.difference me.get('cur_app_list'), cur_item_list
                        me.set 'cur_app_list', cur_item_list
                else if flag == 'stack'
                    if _.difference me.get('cur_stack_list'), cur_item_list
                        me.set 'cur_stack_list', cur_item_list

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

        runApp : (app_id) ->
            me = this

            app_name = i.name for i in me.get('cur_app_list') when i.id == app_id
            app_model.start { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region, app_id, app_name
            app_model.on 'APP_START_RETURN', (result) ->
                console.log 'APP_START_RETURN'
                console.log result

                #parse the result
                if !result.is_error #request successfuly
                    #push event
                    ide_event.trigger ide_event.APP_RUN, app_name, app_id
                #else    # failed

        stopApp : (app_id) ->
            me = this
            app_name = i.name for i in me.get('cur_app_list') when i.id == app_id
            app_model.stop { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region, app_id, app_name
            app_model.on 'APP_STOP_RETURN', (result) ->
                console.log 'APP_STOP_RETURN'
                console.log result

                if !result.is_error
                    ide_event.trigger ide_event.APP_STOP, app_name, app_id

        terminateApp : (app_id) ->
            me = this
            app_name = i.name for i in me.get('cur_app_list') when i.id == app_id
            app_model.terminate { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region, app_id, app_name
            app_model.on 'APP_TERMINATE_RETURN', (result) ->
                console.log 'APP_TERMINATE_RETURN'
                console.log result

                if !result.is_error
                    ide_event.trigger ide_event.APP_TERMINATE, app_name, app_id

        duplicateStack : (stack_id, new_name) ->
            me = this

            # check duplicate stack name

            stack_name = s.name for s in me.get('cur_stack_list') when s.id == stack_id
            # get service, ( src, username, session_id, region_name, stack_id, new_name, stack_name=null )
            stack_model.save_as { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region, stack_id, new_name, stack_name
            stack_model.on 'STACK_SAVE__AS_RETURN', (result) ->
                console.log 'STACK_SAVE__AS_RETURN'
                console.log result

                if !result.is_error
                    ide_event.trigger ide_event.UPDATE_STACK_LIST

        deleteStack : (stack_id) ->
            me = this

            stack_name = s.name for s in me.get('cur_stack_list') when s.id == stack_id
            stack_model.remove { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region, stack_id, stack_name
            stack_model.on 'STACK_REMOVE_RETURN', (result) ->
                console.log 'STACK_REMOVE_RETURN'
                console.log result

                if !result.is_error
                    ide_event.trigger ide_event.ADD_STACK_TAB

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