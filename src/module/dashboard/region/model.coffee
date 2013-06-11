#############################
#  View Mode for dashboard(region)
#############################

define [ 'backbone', 'jquery', 'underscore' ], () ->

    #private
    RegionModel = Backbone.Model.extend {

        defaults :
            temp : null

        initialize : ->
            #
            null

        #temp
        temp : ->
            me = this
            null

    }

    model = new RegionModel()

    return model