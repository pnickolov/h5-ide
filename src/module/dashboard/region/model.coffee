#############################
#  View Mode for dashboard(region)
#############################

define [ 'backbone', 'jquery', 'underscore' ], () ->

    #private
    RegionModel = Backbone.Model.extend {

        defaults :
            cur_app_list    : null
            cur_stack_list  : null

        initialize : ->
            #
            null

        resultListListener : ->
            me = this

            #get service(model)
            ide_event.onListen 'RESULT_APP_LIST', ( result ) ->

                # get current region's apps

                null

            ide_event.onListen 'RESULT_STACK_LIST', ( result ) ->

                # get current region's stacks


                null
            null

        # get all app/stack

        # parse a single app/stack

    }

    model = new RegionModel()

    return model