#############################
#  View Mode for component/sgrule
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], ( constant ) ->

    SGRulePopupModel = Backbone.Model.extend {

        defaults :

            sg_detail : null

            sg_group : [
                    {
                        name  : "DefaultSG"
                        rules : [ {
                            egress     : true
                            protocol   : "TCP"
                            connection : "eni"
                            port       : "1234"
                        } ]
                    }
                ]

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getSgRuleDetail : ( line_id ) ->

            both_side = []

            options = MC.canvas.lineTarget line_id

            $.each options, ( i, connection_obj ) ->

                switch MC.canvas_data.component[connection_obj.uid].type

                    when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

                        if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

                            side_sg = {}

                            side_sg.name = MC.canvas_data.component[connection_obj.uid].name

                            side_sg.sg = ({uid:sg.split('.')[0][1...],name:MC.canvas_data.component[sg.split('.')[0][1...]].name} for sg in MC.canvas_data.component[connection_obj.uid].resource.SecurityGroupId)

                            both_side.push side_sg

                        else

                            $.each MC.canvas_data.component, ( comp_uid, comp ) ->

                                if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (comp.resource.Attachment.InstanceId.split ".")[0][1...] == connection_obj.uid and comp.resource.Attachment.DeviceIndex == '0'

                                    side_sg = {}

                                    side_sg.name = MC.canvas_data.component[connection_obj.uid].name

                                    side_sg.sg = ({name:MC.canvas_data.component[sg.GroupId.split('.')[0][1...]].name, uid:sg.GroupId.split('.')[0][1...]} for sg in comp.resource.GroupSet)

                                    both_side.push side_sg

            this.set 'sg_detail', both_side

    }

    return SGRulePopupModel
