#############################
#  View Mode for design/property/stack
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    StackModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost


        getStackType : ->
            type = MC.canvas_data.platform

            if type == 'ec2-classic'
                return 'Classic'
            else if type == 'ec2-vpc'
                return ''
            else if type == 'default-vpc|custom-vpc'
                return 'Default VPC'
            else if type == 'custom-vpc'
                return 'Custom VPC'

        getSecurityGroup : ->


        getNetworkACL : ->

        getStackCost : ->

    }

    model = new StackModel()

    return model