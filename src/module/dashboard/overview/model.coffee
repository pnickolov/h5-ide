#############################
#  View Mode for dashboard(overview)
#############################

define [ 'event', 'stack_vo', 'app_vo', 'constant', 'vpc_model' ], ( ide_event, stack_vo, app_vo, constant, vpc_model ) ->

    #private
    #region map
    region_labels       = []
    region_counts       = []
    region_aws_list     = []
    region_classic_vpc_list = []
    region_classic_vpc_result = []

    result_list = { 'total_app' : 0, 'total_stack' : 0, 'total_aws' : 0, 'plural_app' : '', 'plural_stack' : '', 'plural_aws' : '', 'region_infos': [] }

    #total count
    total_app   = 0
    total_stack = 0
    total_aws   = 0
    classic_vpc_count = 0

    #keys
    KEYS = [ 'us-east-1', 'us-west-1', 'us-west-2', 'eu-west-1', 'ap-southeast-1', 'ap-southeast-2', 'ap-northeast-1', 'sa-east-1' ]

    OverviewModel = Backbone.Model.extend {

        defaults :
            'result_list'         : null
            'region_classic_list' : null
            'region_empty_list'   : null

        initialize : ->
            #
            region_labels[ 'us-east-1' ]      = 'Virginia'
            region_labels[ 'us-west-1' ]      = 'N. California'
            region_labels[ 'us-west-2' ]      = 'Oregon'
            region_labels[ 'eu-west-1' ]      = 'Ireland'
            region_labels[ 'ap-southeast-1' ] = 'Singapore'
            region_labels[ 'ap-southeast-2' ] = 'Sydney'
            region_labels[ 'ap-northeast-1' ] = 'Tokyo'
            region_labels[ 'sa-east-1' ]      = 'Sao Paulo'

            null

        #temp
        resultListListener : ->

            me = this

            #get service(model)
            ide_event.onListen 'RESULT_STACK_LIST', () ->

                console.log 'RESULT_STACK_LIST'

                me.updateMap( me )

                null

            null


        #result list
        updateMap : (me) ->

            #init
            total_app   = 0
            total_stack = 0
            total_aws   = 0
            result_list.region_infos = []
            region_aws_list          = []

            _.map KEYS, ( value )  ->

                region_counts[value] = { 'running_app' : 0, 'stopped_app' : 0, 'stack' : 0 }

                null

            #onlisten app
            _.map app_vo.app_list, ( value ) ->

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
            _.map stack_vo.stack_list, ( value ) ->

                region_group_obj = value

                _.map region_group_obj.region_name_group, ( value ) ->

                    region_counts[value.region].stack += 1
                    total_stack += 1

                    null

                null

            #
            _.map KEYS, ( value ) ->

                if region_counts[ value ].running_app isnt 0 or region_counts[ value ].stopped_app isnt 0 or region_counts[ value ].stack isnt 0
                    result_list.region_infos.push { 'region_name' : value, 'region_city' : region_labels[ value ], 'running_app' : region_counts[ value ].running_app, 'stopped_app' : region_counts[ value ].stopped_app, 'stack': region_counts[ value ].stack }
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

                diff              = _.difference _.keys( region_labels ), region_aws_list
                empty_list = _.map diff, ( value ) ->
                    return { 'region_name' : value, 'region_city' : region_labels[ value ] }

                #set vo
                me.set 'region_empty_list', empty_list

                null

            null

        #region list
        describeAccountAttributesService : ()->

            me = this

            temp_keys = []
            classic_vpc_count = 0
            _.map KEYS, ( value ) ->
                region_classic_vpc_list[ value ] = null
                temp_keys.push value
                null

            me.getRegionAccountAttribute( temp_keys )

            null

        #get region account attribute
        getRegionAccountAttribute : ( cur_keys )->

            temp = this

            #get service(model)
            vpc_model.DescribeAccountAttributes { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), cur_keys[ 0 ],  ["supported-platforms"]
            vpc_model.on 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', ( result ) ->
                if classic_vpc_count <= 7
                    regionAttrSet = result.resolved_data.accountAttributeSet.item.attributeValueSet
                    cur_key = cur_keys[ 0 ]
                    if region_classic_vpc_list[ cur_key ] is null
                        if regionAttrSet[ 0 ] is 'VPC'
                            region_classic_vpc_list[ cur_key ] = { 'vpc' : 'VPC', 'region_name' : constant.REGION_LABEL[ cur_keys[ 0 ] ] }
                        else
                            region_classic_vpc_list[ cur_key ] = { 'classic' : 'Classic', 'vpc' : 'VPC', 'region_name' : constant.REGION_LABEL[ cur_keys[ 0 ] ] }
                        classic_vpc_count += 1
                        sub_keys = cur_keys.splice( 1 )
                        if sub_keys[ 0 ]
                            temp.getRegionAccountAttribute(sub_keys)
                        else
                            _.map KEYS, ( value ) ->
                                region_classic_vpc_result.push region_classic_vpc_list[value]
                                null
                            temp.set 'region_classic_list', region_classic_vpc_result
                null
            null
    }

    model = new OverviewModel()

    return model