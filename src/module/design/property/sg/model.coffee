#############################
#  View Mode for design/property/instance
#############################

define [ 'constant','backbone', 'jquery', 'underscore', 'MC' ], (constant) ->

    InstanceModel = Backbone.Model.extend {

        defaults :
            'sg_detail'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getSG : ( uid, parent ) ->

            me = this

            sg_detail = {}

            sg_detail.parent = parent

            sg_detail.component = MC.canvas_data.component[uid]

            _.map MC.canvas_property.sg_list, ( value ) ->

                if value.uid == uid

                    sg_detail.members = value.member.length

                    if MC.canvas_data.component[uid].resource.IpPermissionsEgress

                            sg_detail.rules = MC.canvas_data.component[uid].resource.IpPermissions.length + MC.canvas_data.component[uid].resource.IpPermissionsEgress.length
                        else

                            sg_detail.rules = MC.canvas_data.component[uid].resource.IpPermissions.length

                    sg_detail.member_names = []

                    _.map value.member, ( instance_uid ) ->

                        sg_detail.member_names.push MC.canvas_data.component[instance_uid].name

                null

            me.set 'sg_detail', sg_detail

        addSG : ( parent )->

            me = this

            uid = MC.guid()

            component_data = $.extend(true, {}, MC.canvas.SG_JSON.data)

            if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

                delete component_data.resource.IpPermissionsEgress

            component_data.uid = uid

            gen_num = [0...500]

            $.each gen_num, ( num ) ->

                sg_name = 'custom-sg' + num

                existing = false

                _.map MC.canvas_data.component, ( value, key ) ->

                    if value.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup and value.name == sg_name

                        existing = true

                        null

                if not existing

                    component_data.name = sg_name

                    component_data.resource.GroupName = sg_name

                    tmp = {}
                    tmp.uid = uid
                    tmp.name = sg_name
                    tmp.member = [ parent ]

                    MC.canvas_property.sg_list.push tmp

                    return false
            

            

            data = MC.canvas.data.get('component')

            data[uid] = component_data
            
            MC.canvas.data.set('component', data)

            sg_detail = {}

            sg_detail.parent = parent

            sg_detail.component = MC.canvas_data.component[uid]

            sg_detail.members = 1

            sg_detail.rules = 1

            sg_detail.member_names = [ MC.canvas_data.component[parent].name ]

            MC.canvas_data.component[parent].resource.SecurityGroupId.push '@'+uid+'.resource.GroupId'

            me.set 'sg_detail', sg_detail

        setSGName : ( uid, value ) ->

            old_name = MC.canvas_data.component[uid].resource.GroupName

            MC.canvas_data.component[uid].resource.GroupName = value

            MC.canvas_data.component[uid].name = value

            _.map MC.canvas_property.sg_list, ( sg ) ->

                if sg.name == old_name

                    sg.name = value

                null

            null

        setSGRule : ( uid, rule ) ->

            rules = null

            if rule.direction == 'radio_inbound'

                rules = MC.canvas_data.component[uid].resource.IpPermissions
            else
                rules = MC.canvas_data.component[uid].resource.IpPermissionsEgress

            existing = false

            _.map MC.canvas_data.component[uid].resource.IpPermissions, ( existing_rule ) ->

                if existing_rule.ToPort == rule.toport and existing_rule.FromPort == rule.fromport and existing_rule.IpRanges == rule.ipranges and existing_rule.IpProtocol == rule.protocol

                    existing = true

                    null

            if not existing

                tmp = {}
                tmp.ToPort = rule.toport
                tmp.FromPort = rule.fromport
                tmp.IpRanges = rule.ipranges
                tmp.IpProtocol = rule.protocol
                MC.canvas_data.component[uid].resource.IpPermissions.push tmp

            null


        removeSGRule : ( uid, rule ) ->

            sg = MC.canvas_data.component[uid].resource

            if rule.inbound == true

                $.each sg.IpPermissions, ( idx, value ) ->

                    if rule.protocol == value.IpProtocol and rule.fromport.toString() == value.FromPort.toString() and rule.toport.toString() == value.ToPort.toString() and value.IpRanges == rule.iprange

                        sg.IpPermissions.splice idx, 1

                        return false

            else

                $.each sg.IpPermissionsEgress, ( idx, value ) ->

                    if rule.protocol == value.IpProtocol and rule.fromport.toString() == value.FromPort.toString() and rule.toport.toString() == value.ToPort.toString() and value.IpRanges == rule.iprange

                        sg.IpPermissionsEgress.splice idx, 1

                        return false


    }

    model = new InstanceModel()

    return model