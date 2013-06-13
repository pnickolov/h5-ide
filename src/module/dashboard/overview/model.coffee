#############################
#  View Mode for dashboard(overview)
#############################

define [ 'MC', 'event', 'constant', 'vpc_model' ], ( MC, ide_event, constant, vpc_model ) ->

    #private
    #region map
    region_counts       = []
    region_aws_list     = []
    region_classic_vpc_list   = []
    region_classic_vpc_result = []

    result_list = { 'total_app' : 0, 'total_stack' : 0, 'total_aws' : 0, 'plural_app' : '', 'plural_stack' : '', 'plural_aws' : '', 'region_infos': [] }

    #total count
    total_app   = 0
    total_stack = 0
    total_aws   = 0
    region_attr_count   = 0

    # resent items threshold
    RESENT_THRESHOLD = 3

    OverviewModel = Backbone.Model.extend {

        defaults :
            'result_list'         : null
            'region_classic_list' : null
            'region_empty_list'   : null
            # resent results
            'resent_edited_stacks'  : []
            'resent_launched_apps'  : []
            'resent_stoped_apps'    : []

        initialize : ->

            me = this

            vpc_model.on 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', ( result ) ->

                console.log 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'

                regionAttrSet = result.resolved_data.accountAttributeSet.item.attributeValueSet.item
                cur_key = result.param[3]
                if region_classic_vpc_list[ cur_key ] is null
                    region_attr_count += 1
                    if regionAttrSet[ 0 ].attributeValue is 'VPC'
                        region_classic_vpc_list[ cur_key ] = { 'vpc' : 'VPC', 'region_name' : constant.REGION_LABEL[ cur_key ] }
                    else
                        region_classic_vpc_list[ cur_key ] = { 'classic' : 'Classic', 'vpc' : 'VPC', 'region_name' : constant.REGION_LABEL[ cur_key ] }
                    if region_attr_count < 8
                        region_attr_key = constant.REGION_KEYS[ region_attr_count ]
                        me.getRegionAccountAttribute( region_attr_key )
                    else
                        _.map constant.REGION_KEYS, ( value ) ->
                            region_classic_vpc_result.push region_classic_vpc_list[value]
                            null
                        me.set 'region_classic_list', region_classic_vpc_result
                null

            null

        #temp
        resultListListener : ->

            me = this

            #get service(model)
            ide_event.onListen 'RESULT_APP_LIST', ( result ) ->

                me.updateMap( me, result )

                me.updateResentApps( me, result, 'resent_launched_apps' )
                me.updateResentApps( me, result, 'resent_stoped_apps' )

                null

            ide_event.onListen 'RESULT_STACK_LIST', ( result ) ->

                me.updateResentStacks( me, result, 'resent_edited_stacks' )

                null
            null


        #result list
        updateMap : ( me, app_list ) ->

            #init
            total_app   = 0
            total_stack = 0
            total_aws   = 0
            result_list.region_infos = []
            region_aws_list          = []

            _.map constant.REGION_KEYS, ( value )  ->

                region_counts[value] = { 'running_app' : 0, 'stopped_app' : 0, 'stack' : 0 }

                null

            ide_event.onListen 'RESULT_STACK_LIST', ( result ) ->

                #onlisten app
                _.map app_list, ( value ) ->

                    region_group_obj = value

                    _.map region_group_obj.region_name_group, ( value ) ->

                        if value.state is constant.APP_STATE.APP_STATE_RUNNING
                            region_counts[value.region].running_app += 1
                        else if value.state is constant.APP_STATE.APP_STATE_STOPPED
                            region_counts[value.region].stopped_app += 1
                        total_app += 1

                        null

                    null

                #onlisten stack
                _.map result, ( value ) ->

                    region_group_obj = value

                    _.map region_group_obj.region_name_group, ( value ) ->

                        region_counts[value.region].stack += 1
                        total_stack += 1

                        null

                    null

                #
                _.map constant.REGION_KEYS, ( value ) ->

                    if region_counts[ value ].running_app isnt 0 or region_counts[ value ].stopped_app isnt 0 or region_counts[ value ].stack isnt 0
                        result_list.region_infos.push { 'region_name' : value, 'region_city' : constant.REGION_SHORT_LABEL[ value ], 'running_app' : region_counts[ value ].running_app, 'stopped_app' : region_counts[ value ].stopped_app, 'stack': region_counts[ value ].stack }
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

            region_attr_keys          = []
            region_classic_vpc_result = []
            region_attr_count         = 0
            _.map constant.REGION_KEYS, ( value ) ->
                region_classic_vpc_list[ value ] = null
                null

            me.getRegionAccountAttribute( constant.REGION_KEYS[ region_attr_count ] )

            null

        #get region account attribute
        getRegionAccountAttribute : ( cur_key )->

            #get service(model)
            vpc_model.DescribeAccountAttributes { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), cur_key,  ["supported-platforms"]

            null

        # update resently edited stacks
        updateResentStacks : (me, result, flag) ->

            resent_edited_stacks = []

            # parse all stacks
            num = 0
            while num < RESENT_THRESHOLD
                _.map result, ( value ) ->
                    region_group = value

                    _.map region_group.region_name_group, ( value ) ->
                        item = me.parseItem(value, flag)
                        if item
                            resent_edited_stacks.push item
                            num = num + 1

                        null
                    null

            me.set 'resent_edited_stacks', resent_edited_stacks

            null

        # update resently launched apps/stopped apps
        updateResentApps : (me, result, flag) ->
            resent_launched_apps = []
            resent_stoped_apps = []

            # parse all apps
            num = 0
            while num < RESENT_THRESHOLD
                _.map result, (value) ->
                    region_group = value

                    _.map region_group.region_name_group, (value) ->
                        item = me.parseItem(value, flag)
                        if item
                            if flag == 'resent_launched_apps'
                                resent_launched_apps.push item
                            else if flag == 'resent_stoped_apps'
                                resent_stoped_apps.push item
                            num = num + 1

                            null
                        null
                    null
                null

            if flag == 'resent_launched_apps'
                me.set 'resent_launched_apps', resent_launched_apps
            if flag == 'resent_stoped_apps'
                me.set 'resent_stoped_apps', resent_stoped_apps

            null

        # parse items
        parseItem : (value, flag) ->
            # get time interval
            interval = 0
            if flag == 'resent_edited_stacks'
                interval = value.time_update
            else if flag == 'resent_launched_apps'
                interval = value.time_create
            else if flag == 'resent_stoped_apps'
                if value.state != 'Stopped' and value.state != 'Stopping'
                    return
                interval = value.time_update
            else
                return

            return { 'region_label' : constant.REGION_LABEL[value.region], 'name' : value.name, 'interval' : MC.intervalDate(interval) }

            # days = interval/(24*60*60)
            # # check the interval
            # if days >= RESENT_THRESHOLD
            #     return
            # else if days < RESENT_THRESHOLD and days > 1
            #     return { 'region_label' : constant.REGION_LABEL[value.region], 'name' : value.name, 'interval' : days + ' days ago' }
            # else if days == 1
            #     return { 'region_label' : constant.REGION_LABEL[value.region], 'name' : value.name, 'interval' : '1 day ago' }
            # else
            #     return { 'region_label' : constant.REGION_LABEL[value.region], 'name' : value.name, 'interval' : Math.floor(interval/60) + ' min ago' }
    }

    model = new OverviewModel()

    return model