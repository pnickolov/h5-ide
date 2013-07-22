#############################
#  View Mode for design/property/rtb
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    RTBModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'route_table'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getRoute : ( uid ) ->

            rt = $.extend true, {}, MC.canvas_data.component[uid]

            this.set 'route_table', rt
            
    }

    model = new RTBModel()

    return model