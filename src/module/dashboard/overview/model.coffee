#############################
#  View Mode for dashboard(overview)
#############################

define [ 'MC', 'event', 'constant', 'vpc_model' ], ( MC, ide_event, constant, vpc_model ) ->

    #private
    #region map
    region_counts       = []
    region_aws_list     = []
    region_classic_vpc_result = []

    result_list = { 'total_app' : 0, 'total_stack' : 0, 'total_aws' : 0, 'plural_app' : '', 'plural_stack' : '', 'plural_aws' : '', 'region_infos': [] }

    #total count
    total_app   = 0
    total_stack = 0
    total_aws   = 0

    #region_tooltip
    region_tooltip = [
        "arrow-left map-tooltip-pointer-left",
        "arrow-up map-tooltip-pointer-up",
        "arrow-down map-tooltip-pointer",
        "arrow-down map-tooltip-pointer",
        "arrow-down map-tooltip-pointer",
        "arrow-down map-tooltip-pointer",
        "arrow-down map-tooltip-pointer",
        "arrow-down map-tooltip-pointer"
    ]

    OverviewModel = Backbone.Model.extend {

        defaults :
            'result_list'         : null
            'region_classic_list' : null
            'region_empty_list'   : null
            # recent results
            'recent_edited_stacks'  : null
            'recent_launched_apps'  : null
            'recent_stoped_apps'    : null
            #'app_list'              : null
            #'stack_list'            : null

        initialize : ->

            me = this

            null

        #temp
        resultListListener : ->

            me = this

            ###
            #get service(model)
            ide_event.onListen 'RESULT_APP_LIST', ( result ) ->

                me.updateMap( me, result )

                me.updateRecentList( me, result, 'recent_launched_apps' )
                me.updateRecentList( me, result, 'recent_stoped_apps' )

                null

            ide_event.onListen 'RESULT_STACK_LIST', ( result ) ->

                me.updateRecentList( me, result, 'recent_edited_stacks' )

                null
            ###
            null

        #result list
        updateMap : ( me, app_list, stack_list ) ->

            #init
            total_app   = 0
            total_stack = 0
            total_aws   = 0
            result_list.region_infos = []
            region_aws_list          = []

            _.map constant.REGION_KEYS, ( value, key )  ->

                region_counts[value] = { 'running_app': 0, 'stopped_app': 0, 'stack': 0 }

                null

            _.map app_list, ( value ) ->

                region_group_obj = value

                _.map region_group_obj.region_name_group, ( value ) ->
                    if value.state is constant.APP_STATE.APP_STATE_RUNNING
                        region_counts[value.region].running_app += 1
                    else if value.state is constant.APP_STATE.APP_STATE_STOPPED
                        region_counts[value.region].stopped_app += 1
                    total_app += 1

                    if value.region in constant.REGION_KEYS and value.name not in MC.data.app_list[value.region]
                        MC.data.app_list[value.region].push value.name

                    null

                null

            #onlisten stack
            _.map stack_list, ( value ) ->

                region_group_obj = value

                _.map region_group_obj.region_name_group, ( value ) ->

                    region_counts[value.region].stack += 1
                    total_stack += 1

                    if value.region in constant.REGION_KEYS and value.name not in MC.data.stack_list[value.region]
                        MC.data.stack_list[value.region].push value.name

                    null

                null

            #
            _.map constant.REGION_KEYS, ( value, key ) ->

                if region_counts[ value ].running_app isnt 0 or region_counts[ value ].stopped_app isnt 0 or region_counts[ value ].stack isnt 0
                    result_list.region_infos.push { 'region_name' : value, 'region_city' : constant.REGION_SHORT_LABEL[ value ], 'running_app' : region_counts[ value ].running_app, 'stopped_app' : region_counts[ value ].stopped_app, 'stack': region_counts[ value ].stack, 'pointer': region_tooltip[key] }
                    region_aws_list.push value

                null

            total_aws = region_aws_list.length

            #set data for result_list
            result_list.total_app    = total_app
            result_list.total_stack  = total_stack
            result_list.total_aws    = total_aws
            result_list.plural_app   = if total_app > 1 then 's' else ''
            result_list.plural_aws   = if total_aws > 1 then 's' else ''
            result_list.plural_stack = if total_stack > 1 then 's' else ''

            #set vo
            me.set 'result_list', result_list

            null

        #empty list
        emptyListListener : ->

            me = this

            #get service(model)
            ide_event.onListen 'RESULT_EMPTY_REGION_LIST', () ->

                console.log 'RESULT_EMPTY_REGION_LIST'

                diff       = _.difference _.keys( constant.REGION_SHORT_LABEL ), region_aws_list
                empty_list = _.map diff, ( value ) ->
                    return { 'region_name' : value, 'region_city' : constant.REGION_SHORT_LABEL[ value ] }

                #set vo
                me.set 'region_empty_list', empty_list

                null

            null

        #region list
        describeAccountAttributesService : ()->

            me = this

            region_classic_vpc_result = []

            #get service(model)
            vpc_model.DescribeAccountAttributes { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), '',  ["supported-platforms"]

            vpc_model.once 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', ( result ) ->

                console.log 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'

                regionAttrSet = result.resolved_data

                _.map constant.REGION_KEYS, ( value ) ->

                    if regionAttrSet[ value ] and regionAttrSet[ value ].accountAttributeSet

                        cur_attr = regionAttrSet[ value ].accountAttributeSet.item[0].attributeValueSet.item
                        if $.type(cur_attr) == "array"
                            region_classic_vpc_result.push { 'classic' : 'Classic', 'vpc' : 'VPC', 'region_name' : constant.REGION_LABEL[ value ], 'region': value }
                        else
                            region_classic_vpc_result.push { 'vpc' : 'VPC', 'region_name' : constant.REGION_LABEL[ value ], 'region': value }
                        null

                me.set 'region_classic_list', region_classic_vpc_result
                null

            null

        # update recent list
        updateRecentList : (me, result, flag) ->
            recent_list = []
            #item_list = []

            _.map result, (value) ->
                region_group_obj = value

                #item_list.push {'region_name' : value., 'items' : value }
                items = []
                region_name = null
                _.map region_group_obj.region_name_group, (value) ->
                    region_name = value.region
                    items.push value

                    item = me.parseItem(value, flag)
                    if item
                        recent_list.push item

                        null

                #item_list.push { 'region_name' : region_name, 'items' : items }

            # sort
            recent_list.sort (a, b) ->
                return if a.interval <= b.interval then 1 else -1

            # time filter
            now = Date.now()/1000
            recent_list = (i for i in recent_list when Math.ceil((now-i.interval)/86400) <= constant.RECENT_DAYS)
            # number filter
            if recent_list.length > constant.RECENT_NUM
                recent_list = recent_list[0..(constant.RECENT_NUM-1)]

            # set value
            if flag == 'recent_edited_stacks'
                me.set 'recent_edited_stacks', recent_list
                #me.set 'stack_list', item_list
            else if flag == 'recent_launched_apps'
                me.set 'recent_launched_apps', recent_list
                #me.set 'app_list', item_list
            else if flag == 'recent_stoped_apps'
                me.set 'recent_stoped_apps', recent_list

        # parse items
        parseItem : (value, flag) ->
            # get time interval
            interval = 0
            if flag == 'recent_edited_stacks'
                interval = value.time_update
            else if flag == 'recent_launched_apps'
                interval = value.time_create
            else if flag == 'recent_stoped_apps' and value.state in ['Stopping', 'Stopped']
                interval = value.time_update

            if interval
                return { 'id' : value.id, 'region' : value.region, 'region_label' : constant.REGION_LABEL[value.region], 'name' : value.name, 'interval_date': MC.intervalDate(interval), 'interval' : interval }

    }

    model = new OverviewModel()

    return model