#############################
#  View Mode for design/property/acl
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    ACLModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new ACLModel()

    return model