#############################
#  View Mode for design/property/instance
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    InstanceModel = Backbone.Model.extend {

        defaults :
            'set_host'    : null
            'get_host'    : null

        initialize : ->
            #listen
            this.listenTo this, 'change:get_host', this.getHost

        setHost  : ( value ) ->
            console.log 'setHost = ' + value
            #this.set 'set_host', MC.canvas_data.component[ value ].name
            this.set 'set_host', 'host'

        getHost  : ->
            console.log 'getHost'
            console.log this.get 'get_host'

    }

    model = new InstanceModel()

    return model