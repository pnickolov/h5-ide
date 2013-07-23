#############################
#  View Mode for design/property/acl
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    ACLModel = Backbone.Model.extend {

        defaults :
            'component'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        init : (uid) ->

            allComp = MC.canvas_data.component
            aclObj = MC.canvas_data.component[uid]
            aclObj.name = 'sadasdsadsadsad'
            this.set 'component', aclObj

            null

    }

    model = new ACLModel()

    return model