#############################
#  View(UI logic) for navigation
#############################

define [ 'event', 'app_model', 'stack_model', 'ec2_model' , 'backbone', 'jquery', 'underscore' ], ( event, app_model, stack_model, ec2_model ) ->

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

    #region map
    region_labels = []

    NavigationModel = Backbone.Model.extend {

        defaults :
            'app_list'    : null
            'stack_list'  : null
            'region_list' : null

        initialize : ->

            region_labels[ 'us-east-1' ]      = 'US East (Virginia)'
            region_labels[ 'us-west-1' ]      = 'US West (N. California)'
            region_labels[ 'us-west-2' ]      = 'US West (Oregon)'
            region_labels[ 'eu-west-1' ]      = 'EU West (Ireland)'
            region_labels[ 'ap-southeast-1' ] = 'Asia Pacific (Singapore)'
            region_labels[ 'ap-southeast-2' ] = 'Asia Pacific (Sydney)'
            region_labels[ 'ap-northeast-1' ] = 'Asia Pacific (Tokyo)'
            region_labels[ 'sa-east-1' ]      = 'South America (Sao Paulo)'

            null

        #app list
        appListService : ->

            me = this

            #get service(model)
            app_model.list { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null
            app_model.on 'APP_LST_RETURN', ( result ) ->
                
                console.log 'APP_LST_RETURN'
                console.log result

                #
                app_list = _.map result.resolved_data, ( value, key ) -> return { 'region_group' : region_labels[ key ], 'region_count' : value.length, 'region_name_group' : value }

                console.log app_list

                #set vo
                me.set 'app_list', app_list

                null

        #stack list
        stackListService : ->

            me = this

            #get service(model)
            stack_model.list { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null
            stack_model.on 'STACK_LST_RETURN', ( result ) ->
                
                console.log 'STACK_LST_RETURN'
                console.log result

                #
                stack_list = _.map result.resolved_data, ( value, key ) -> return { 'region_group' : region_labels[ key ], 'region_count' : value.length, 'region_name_group' : value }

                console.log stack_list

                #set vo
                me.set 'stack_list', stack_list

                null

        #region list
        describeRegionsService : ->

            me = this

            #get service(model)
            ec2_model.DescribeRegions { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null
            ec2_model.on 'EC2_EC2_DESC_REGIONS_RETURN', ( result ) ->

                console.log 'EC2_EC2_DESC_REGIONS_RETURN'
                console.log result

                #
                region_list = _.map result.resolved_data.item, ( value, key ) ->
                
                    region_city = region_labels[ value.regionName ].split( '(' )[1].replace( /\)/g, '' )
                    region_area = region_labels[ value.regionName ].split( '(' )[0]
                
                    return { 'region_city' : region_city, 'region_area' : region_area }

                console.log region_list

                #set vo
                me.set 'region_list', region_list

                #console.log me.get 'region_list'


    }

    model = new NavigationModel()

    return model