#############################
#  View Mode for dashboard(overview)
#############################

define [ 'MC', 'event', 'constant', 'vpc_model', 'aws_model', 'app_model', 'stack_model' ], ( MC, ide_event, constant, vpc_model, aws_model, app_model, stack_model ) ->

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
            'cur_app_list'          : null
            'cur_stack_list'        : null
            'global_list'           : {}
            'region_list'           : {}
            'cur_region_list'       : {}


        initialize : ->

            me = this

            #listen VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN

            @on 'AWS_RESOURCE_RETURN', @awsReturnHandler
            @on 'APP_INFO_RETURN', @appInfoHandler

            @on 'STACK_LST_RETURN', @stackReturnHandler
            @on 'APP_LST_RETURN', @appReturnHandler

            vpc_model.on 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', ( result ) ->

                console.log 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'

                region_classic_vpc_result = []

                if !result.is_error

                    regionAttrSet = result.resolved_data

                    _.map constant.REGION_KEYS, ( value ) ->
                        if regionAttrSet[ value ] and regionAttrSet[ value ].accountAttributeSet

                            #resolve support-platform
                            support_platform = regionAttrSet[ value ].accountAttributeSet.item[0].attributeValueSet.item
                            if support_platform and $.type(support_platform) == "array"
                                if support_platform.length == 2
                                    MC.data.account_attribute[ value ].support_platform = support_platform[0].attributeValue + ',' + support_platform[1].attributeValue
                                    region_classic_vpc_result.push { 'classic' : 'Classic', 'vpc' : 'VPC', 'region_name' : constant.REGION_SHORT_LABEL[ value ], 'region': value }
                                else if support_platform.length == 1
                                    MC.data.account_attribute[ value ].support_platform = support_platform[0].attributeValue
                                    region_classic_vpc_result.push { 'vpc' : 'VPC', 'region_name' : constant.REGION_SHORT_LABEL[ value ], 'region': value }

                            #resolve default-vpc
                            default_vpc = regionAttrSet[ value ].accountAttributeSet.item[1].attributeValueSet.item
                            if  default_vpc and $.type(default_vpc) == "array" and default_vpc.length == 1
                                MC.data.account_attribute[ value ].default_vpc = default_vpc[0].attributeValue

                            null

                    me.set 'region_classic_list', region_classic_vpc_result

                    # set cookie
                    if $.cookie('has_cred') isnt 'true'
                        $.cookie 'has_cred', true,    { expires: 1 }
                        ide_event.trigger ide_event.UPDATE_AWS_CREDENTIAL

                    null

                else
                    # set cookie
                    if $.cookie('has_cred') isnt 'false'
                        $.cookie 'has_cred', false,    { expires: 1 }
                        ide_event.trigger ide_event.UPDATE_AWS_CREDENTIAL

                    me.set 'region_classic_list', region_classic_vpc_result

            null

        awsReturnHandler: ( result ) ->
            data = result.resolved_data
            region = result.param[ 3 ]
            if region is null
                # update regionlist for optimize network
                @cacheResource data

                globalData = @globalRegionhandle data
                @set 'global_list', globalData
            else
                regionData = @regionHandel data[ region ]
                oriRegionList = @get 'region_list'
                oriRegionList[ region ] = regionData
                @set 'region_list', oriRegionList
                @set 'cur_region_list', regionData

        cacheResource: ( data ) ->
            regionList = @get 'region_list'
            _.each data, ( resource, region ) =>
                if not regionList[ region ]
                    regionList[ region ] = @regionHandel resource
                null
            @set 'region_list', regionList

        globalRegionhandle: ( data ) ->
            midData = retData = {}
            # region and type maps
            regions = _.keys constant.REGION_LABEL
            types = [ 'DescribeInstances', 'DescribeAddresses', 'DescribeVolumes', 'DescribeLoadBalancers', 'DescribeVpnConnections' ]
            # initial
            _.each regions, ( region ) ->
                value = data[ region ]
                _.each types, ( type ) ->
                    v = value[ type ]
                    if type is 'DescribeInstances'
                        v = _.filter v, ( vv ) ->
                            return vv.instanceState.name is 'running'
                    midData[ type ] = {} if not midData[ type ]
                    midData[ type ][ region ] = v
                    null

            # structure for handlebars
            _.each midData, ( value, type ) ->
                retData[ type ] = { data: [], total: 0 }

                _.each value, ( v, region ) ->
                    vTotal = v and v.length or 0
                    if vTotal
                        retData[ type ].total += vTotal
                    retData[ type ].data.push
                        region: region
                        city: constant.REGION_SHORT_LABEL[ region ]
                        area: constant.REGION_LABEL[ region ]
                        total: vTotal
            # sort
            _.each retData, ( value, type ) ->
                value.data = _.sortBy value.data, ( v ) ->
                    - v.total
                null

            retData



        regionHandel: ( data ) ->
            retData = {}

            _.each data, ( value, type ) ->
                retData[ type ] =
                    data: value
                    total: value and value.length or 0
                null
            retData

        loadResource: ( region ) ->
            if ( @get 'region_list' )[ region ]
                @set 'cur_region_list', ( @get 'region_list' )[ region ]
                return

            @describeAWSResourcesService region




        ############################################################################################

         #result list
        updateMap : ( me, app_list, stack_list ) ->

            #init
            total_app   = 0
            total_stack = 0
            total_aws   = 0
            result_list.region_infos = []
            region_aws_list          = []

            #global stack name list
            MC.data.stack_list = {}
            MC.data.stack_list[r] = [] for r in constant.REGION_KEYS
            #global app name list
            MC.data.app_list = {}
            MC.data.app_list[r] = [] for r in constant.REGION_KEYS

            _.map constant.REGION_KEYS, ( value, key )  ->

                region_counts[value] = { 'running_app': 0, 'stopped_app': 0, 'stack': 0, 'app': 0 }

                null

            _.map app_list, ( value ) ->

                region_group_obj = value

                _.map region_group_obj.region_name_group, ( value ) ->
                    if value.state is constant.APP_STATE.APP_STATE_RUNNING
                        region_counts[value.region].running_app += 1
                    else if value.state is constant.APP_STATE.APP_STATE_STOPPED
                        region_counts[value.region].stopped_app += 1
                    total_app += 1
                    region_counts[value.region].app += 1

                    if value.region in constant.REGION_KEYS
                        MC.data.app_list[value.region].push value.name

                    null

                null

            #onlisten stack
            _.map stack_list, ( value ) ->

                region_group_obj = value

                _.map region_group_obj.region_name_group, ( value ) ->

                    region_counts[value.region].stack += 1
                    total_stack += 1

                    if value.region in constant.REGION_KEYS
                        MC.data.stack_list[value.region].push { id: value.id, name: value.name }

                    null

                null

            #
            _.map constant.REGION_KEYS, ( value, key ) ->

                if region_counts[ value ].app isnt 0 or region_counts[ value ].stack isnt 0
                    result_list.region_infos.push { 'region_name' : value, 'region_city' : constant.REGION_SHORT_LABEL[ value ], 'app':region_counts[ value ].app , 'running_app' : region_counts[ value ].running_app, 'stopped_app' : region_counts[ value ].stopped_app, 'stack': region_counts[ value ].stack, 'pointer': region_tooltip[key] }
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

        # get current region's app/stack list
        getItemList : ( flag, region, result ) ->
            me = this

            item_list = regions.region_name_group for regions in result when constant.REGION_SHORT_LABEL[ region ] == regions.region_group

            cur_item_list = []
            _.map item_list, (value) ->
                item = me.parseItemList(value, flag)
                if item
                    cur_item_list.push item

                    null

            if cur_item_list
                #sort
                cur_item_list.sort (a,b) ->
                    return if a.create_time <= b.create_time then 1 else -1

                if flag == 'app'
                    #difference
                    if _.difference me.get('cur_app_list'), cur_item_list
                        me.set 'cur_app_list', cur_item_list
                        me.trigger 'UPDATE_REGION_APP_LIST'

                else if flag == 'stack'
                    if _.difference me.get('cur_stack_list'), cur_item_list
                        me.set 'cur_stack_list', cur_item_list
                        me.trigger 'UPDATE_REGION_STACK_LIST'



        #region list
        describeAccountAttributesService : ()->

            me = this

            #get service(model)
            vpc_model.DescribeAccountAttributes { sender : vpc_model }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), '',  ["supported-platforms","default-vpc"]

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

        parseItemList : (item, flag) ->
            me = this

            id          = item.id
            name        = item.name
            create_time = item.time_create
            id_code     = item.key

            update_time =  Math.round(+new Date())

            status      = "play"
            isrunning   = true
            ispending   = false

            # check state
            if item.state == constant.APP_STATE.APP_STATE_INITIALIZING    #constant.APP_STATE.APP_STATE_STOPPING or
                return
            else if item.state == constant.APP_STATE.APP_STATE_RUNNING
                status = "play"
            else if item.state == constant.APP_STATE.APP_STATE_STOPPED
                isrunning = false
                status = "stop"
            else
                status = "pending"
                ispending = true

            has_instance_store_ami = false

            if flag == 'app'
                date = new Date()
                start_time = null
                stop_time = null

                has_instance_store_ami = if 'has_instance_store_ami' of item and item.has_instance_store_ami then item.has_instance_store_ami else false

                if item.last_start
                    date.setTime(item.last_start*1000)
                    start_time  = "GMT " + MC.dateFormat(date, "hh:mm yyyy-MM-dd")
                if not isrunning and item.last_stop
                    date.setTime(item.last_stop*1000)
                    stop_time = "GMT " + MC.dateFormat(date, "hh:mm yyyy-MM-dd")

            return { 'id' : id, 'code' : id_code, 'update_time' : update_time , 'name' : name, 'create_time':create_time, 'start_time' : start_time, 'stop_time' : stop_time, 'isrunning' : isrunning, 'ispending' : ispending, 'status' : status, 'cost' : "$0/month", 'has_instance_store_ami' : has_instance_store_ami }

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
                return { 'id' : value.id, 'region' : value.region, 'region_label' : constant.REGION_SHORT_LABEL[value.region], 'name' : value.name, 'interval_date': MC.intervalDate(interval), 'interval' : interval }
                #app list


        describeAWSResourcesService : ( region )->
            me = this
            region = region or null
            current_region = region

            res_type = constant.AWS_RESOURCE

            resources = {}
            resources[res_type.INSTANCE]  =   {}
            resources[res_type.EIP]       =   {}
            resources[res_type.VOLUME]    =   {}
            resources[res_type.VPC]       =   {}
            resources[res_type.VPN]       =   {}
            resources[res_type.ELB]       =   {}
            resources[res_type.ASG]       =   {}
            resources[res_type.CLW]       =   {}
            resources[res_type.SNS_SUB]   =   {}

            aws_model.resource { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region,  resources

        updateAppList : (flag, app_id) ->
            me = this

            cur_app_list = me.get 'cur_app_list'

            if flag is 'pending'
                for item in cur_app_list
                    if item.id == app_id
                        idx = cur_app_list.indexOf item
                        if idx>=0
                            cur_app_list[idx].status = "pending"
                            cur_app_list[idx].ispending = true

                            me.set 'cur_app_list', cur_app_list
                            #me.trigger 'UPDATE_REGION_APP_LIST'

            null

    }

    model = new OverviewModel()

    return model
