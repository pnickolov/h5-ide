#############################
#  View Mode for design/property/instance
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC', 'constant' ], () ->

    InstanceModel = Backbone.Model.extend {

        defaults :
            'set_host'    : null
            'get_host'    : null

        initialize : ->
            #listen
            this.listenTo this, 'change:get_host', this.getHost

        setHost  : ( uid, value ) ->
            console.log 'setHost = ' + value
            MC.canvas_data.component[ uid ].name = value

            null
            #this.set 'set_host', 'host'

        getHost  : ->
            console.log 'getHost'
            console.log this.get 'get_host'

        getInstanceType : (uid) ->
            console.log uid

        _getInstanceType : ( ami ) ->
            instance_type = MC.data.instance_type
            if ami.virtualizationType == 'hvm'
                instance_type = instance_type.windows
            else
                instance_type = instance_type.linux
            if ami.rootDeviceType == 'ebs'
                instance_type = instance_type.ebs
            else
                instance_type = instance_type['instance store']
            if ami.architecture == 'x86_64'
                instance_type = instance_type["64"]
            else
                instance_type = instance_type["32"]
            instance_type = instance_type[ami.virtualizationType]

            instance_type.join ', '
    }

    model = new InstanceModel()

    return model