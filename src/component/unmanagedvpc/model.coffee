#############################
#  View Mode for component/unmanagedvpc
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    UnmanagedVPCModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    return UnmanagedVPCModel