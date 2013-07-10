#############################
#  View Mode for design/property/instance
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], (constant) ->

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

        setInstanceType  : ( uid, value ) ->
            console.log 'setInstanceType = ' + value
            MC.canvas_data.component[ uid ].resource.InstanceType = value
            null
            #this.set 'set_host', 'host'

        getHost  : ->
            console.log 'getHost'
            console.log this.get 'get_host'

        getKerPair : ->
            _.map MC.canvas_data.component, (value, key) ->

                if value.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair

                    console.log value.resource.KeyName

        getInstanceType : (uid) ->
            console.log uid
            ami_info = MC.canvas_data.layout.component.node[ uid ]

            current_instance_type = MC.canvas_data.component[ uid ].resource.InstanceType

            view_instance_type = []
            instance_types = this._getInstanceType ami_info
            _.map instance_types, ( value )->
                tmp = {}

                if current_instance_type == value
                    tmp.selected = true
                tmp.main = constant.INSTANCE_TYPE[value][0]
                tmp.ecu  = constant.INSTANCE_TYPE[value][1]
                tmp.core = constant.INSTANCE_TYPE[value][2]
                tmp.mem  = constant.INSTANCE_TYPE[value][3]
                tmp.name = value
                view_instance_type.push tmp

            view_instance_type

        _getInstanceType : ( ami ) ->
            instance_type = MC.data.instance_type[MC.canvas_data.region]
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

            instance_type
    }

    model = new InstanceModel()

    return model