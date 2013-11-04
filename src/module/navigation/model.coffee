#############################
#  View Mode for navigation
#############################

define [ 'app_model', 'stack_model', 'ec2_model', 'constant', 'backbone', 'jquery', 'underscore' ], ( app_model, stack_model, ec2_model, constant ) ->

    ###
    regions = [{
        region_group: "Band"
        region_count: 3
        region_name_group: [
            { name : "Generic Name"         },
            { name : "Something Else!!"     },
            { name : "Something Else!!3333" }
        ]
        },{
        region_group: "Band2"
        region_count: 2
        region_name_group: [
            { name : "Generic Name444"     },
            { name : "Something Else!!555" }
        ]
    }]
    ###

    #private
    #region map
    #region_labels  = []
    #stack region id
    stack_region_list = []

    #private
    NavigationModel = Backbone.Model.extend {

        defaults :
            'app_list'          : null
            'stack_list'        : null
            'region_list'       : null
            'region_empty_list' : null

        initialize : ->

            me = this

            #####listen APP_LST_RETURN
            me.on 'APP_LST_RETURN', ( result ) ->

                console.log 'APP_LST_RETURN'

                return if result.is_error

                ids = result.param[4]
                app_list = []

                if ids
                    new_app_list = _.map result.resolved_data, ( value, key ) -> return { 'region_group' : constant.REGION_SHORT_LABEL[ key ], 'region_count' : value.length, 'region_name_group' : value }
                    app_list = _.union(app_list, new_app_list)

                else
                    app_list = _.map result.resolved_data, ( value, key ) -> return { 'region_group' : constant.REGION_SHORT_LABEL[ key ], 'region_count' : value.length, 'region_name_group' : value }

                console.log app_list

                #set vo
                me.set 'app_list', app_list

                null

            #####listen STACK_LST_RETURN
            me.on 'STACK_LST_RETURN', ( result ) ->

                console.log 'STACK_LST_RETURN'

                return if result.is_error

                ids = result.param[4]
                stack_list = []

                if ids
                    new_stack_list = _.map result.resolved_data, ( value, key ) -> return { 'region_group' : constant.REGION_SHORT_LABEL[ key ], 'region_count' : value.length, 'region_name_group' : value }
                    stack_list = _.union(stack_list, new_stack_list)

                else
                    stack_list = _.map result.resolved_data, ( value, key ) -> return { 'region_group' : constant.REGION_SHORT_LABEL[ key ], 'region_count' : value.length, 'region_name_group' : value }

                console.log stack_list

                #
                #me.regionEmptyList _.keys result.resolved_data
                stack_region_list = _.keys result.resolved_data

                #set vo
                me.set 'stack_list', stack_list

                null


            #####listen EC2_EC2_DESC_REGIONS_RETURN
            me.on 'EC2_EC2_DESC_REGIONS_RETURN', ( result ) ->

                console.log 'EC2_EC2_DESC_REGIONS_RETURN'

                region_list = []

                if !result.is_error
                    region_list = _.map result.resolved_data.item, ( value, key ) ->

                        region_city = constant.REGION_SHORT_LABEL[ value.regionName ]
                        region_area = constant.REGION_LABEL[ value.regionName ]

                        return { 'region_city' : region_city, 'region_area' : region_area, 'region_name' : value.regionName }

                else
                    region_list = _.map constant.REGION_KEYS, (region) ->

                        region_city = constant.REGION_SHORT_LABEL[ region ]
                        region_area = constant.REGION_LABEL[ region ]

                        return { 'region_city' : region_city, 'region_area' : region_area, 'region_name' : region }

                console.log region_list

                #set vo
                me.set 'region_list', region_list

                null


            null

        #app list
        appListService : (flag, ids) ->

            me = this

            #get service(model)
            if flag and ids and flag is 'TERMINATE_APP'     # delete item from list when terminated app
                new_app_list = []
                app_list = me.get 'app_list'

                for rv in app_list
                    region_list = []
                    for item in rv.region_name_group
                        if item.id in ids
                            continue

                        region_list.push item

                    new_app_list.push {'region_name_group':region_list, 'region_group':rv.region_group, 'region_count':region_list.length}

                me.set 'app_list', new_app_list

            else
                app_model.list { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, ids


        #stack list
        stackListService : (flag, ids) ->

            me = this

            #get service(model)
            if flag and ids and flag is 'REMOVE_STACK'
                new_stack_list = []
                stack_list = me.get 'stack_list'

                for rv in stack_list
                    region_list = []
                    for item in rv.region_name_group
                        if item.id in ids
                            continue

                        region_list.push item

                    new_stack_list.push {'region_name_group':region_list, 'region_group':rv.region_group, 'region_count':region_list.length}

                me.set 'stack_list', new_stack_list

            else
                stack_model.list { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null


        #region empty list
        regionEmptyList : () ->

            console.log 'regionEmptyList'

            diff              = _.difference _.keys( constant.REGION_SHORT_LABEL ), stack_region_list
            region_empty_list = _.map diff, ( val ) -> return constant.REGION_SHORT_LABEL[ val ]

            console.log region_empty_list

            #set vo
            this.set 'region_empty_list', region_empty_list

            null

        #region list
        describeRegionsService : ->

            me = this

            #get service(model)
            ec2_model.DescribeRegions { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null

    }

    model = new NavigationModel()

    return model
