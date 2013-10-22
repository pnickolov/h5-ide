#############################
#  View Mode for design/property/cgw
#############################

define [ '../base/model', 'constant' ], ( PropertyModel, constant ) ->

    ConnectionModel = PropertyModel.extend {

        init : ( uid ) ->

            line_option = MC.canvas.lineTarget uid

            if line_option.length != 2
                return false

            portMap = {}
            portMap[ line_option[0].port ] = line_option[0].uid
            portMap[ line_option[1].port ] = line_option[1].uid

            components = MC.canvas_data.component

            # If the line is Eni <=> Instance
            if portMap["eni-attach"] and portMap["instance-attach"]
                asso = {
                    eni : components[ portMap['eni-attach'] ].serverGroupName
                    instance : components[ portMap['instance-attach'] ].serverGroupName
                }
                @set "eniAsso", asso
                @set "name", "Instance-ENI Attachment"
            else if portMap["elb-assoc"] and portMap["subnet-assoc-in"]
                asso = {
                    elb : components[ portMap['elb-assoc'] ].name
                    subnet : components[ portMap['subnet-assoc-in'] ].name
                }
                @set "subnetAsso", asso
                @set "name", "Load Balancer-Subnet Association"
            null
    }

    new ConnectionModel()
