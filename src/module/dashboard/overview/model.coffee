#############################
#  View Mode for dashboard(overview)
#############################

define [ 'app_model', 'stack_model', 'ec2_model' , 'backbone', 'jquery', 'underscore' ], ( app_model, stack_model, ec2_model) ->

    #private
    #region map
    region_labels  = []
    #stack region id
    stack_region_list = []

    OverviewModel = Backbone.Model.extend {

        defaults :
            'app_list'          : null
            'stack_list'        : null
            'region_list'       : null
            'region_empty_list' : null

        initialize : ->
            #
            null

        #temp
        temp : ->
            me = this
            null

        #app list
        appListService : ->

            me = this

            console.log 'overview_init_model'

            #get service(model)
            app_model.on 'RESULT_APP_LIST', ( result ) ->

                console.log 'Overview_APP_LST_RETURN'
                console.log result

                #
                app_list = _.map result.resolved_data, ( value, key ) -> return { 'region_group' : region_labels[ key ], 'region_count' : value.length, 'region_name_group' : value }

                console.log app_list

                #set vo
                me.set 'app_list', app_list

                null
    }

    model = new OverviewModel()

    return model