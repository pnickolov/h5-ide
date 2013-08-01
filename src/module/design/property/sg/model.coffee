#############################
#  View Mode for design/property/instance
#############################

define [ 'constant','backbone', 'jquery', 'underscore', 'MC' ], (constant) ->

    SgModel = Backbone.Model.extend {

        defaults :
            'sg_detail'    : null
            'sg_app_detail' : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getSG : ( uid, parent ) ->

            me = this

            sg_detail = {}

            # sg_detail.parent = parent

            sg_detail.component = MC.canvas_data.component[uid]

            sg_detail.rules = MC.canvas_data.component[uid].resource.IpPermissions.length + MC.canvas_data.component[uid].resource.IpPermissionsEgress.length

            sg_detail.members = MC.aws.sg.getAllRefComp(uid)

            me.set 'sg_detail', sg_detail

        getAppSG : ( sg_uid ) ->

            # get sg obj
            currentRegion = MC.canvas_data.region
            currentSGComp = MC.canvas_data.component[sg_uid]
            currentSGID = currentSGComp.resource.GroupId
            currentAppSG = MC.data.resource_list[currentRegion][currentSGID]

            members = MC.aws.sg.getAllRefComp sg_uid
            rules = MC.aws.sg.getAllRule currentAppSG

            #get sg name
            sg_app_detail =
                groupName : currentAppSG.groupName
                groupDescription : currentAppSG.groupDescription
                groupId : currentAppSG.groupId
                ownerId : currentAppSG.ownerId
                vpcId : currentAppSG.vpcId
                members : members
                rules : rules

            this.set 'sg_app_detail', sg_app_detail

        addSG : ( parent )->

            me = this

            uid = MC.guid()

            component_data = $.extend(true, {}, MC.canvas.SG_JSON.data)

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

                    # if parent
                    #     tmp.member = [ parent ]

                    MC.canvas_property.sg_list.push tmp

                    return false
            

            

            data = MC.canvas.data.get('component')

            data[uid] = component_data
            
            MC.canvas.data.set('component', data)

            sg_detail = {}

            sg_detail.component = MC.canvas_data.component[uid]

            sg_detail.members = 1

            sg_detail.rules = 1

            # if parent

            #     sg_detail.parent = parent

            #     sg_detail.member_names = [ MC.canvas_data.component[parent].name ]

            #     if MC.canvas_data.platform != MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

            #         $.each MC.canvas_data.component, ( key, comp ) ->

            #             if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId.split('.')[0][1...] == parent and comp.resource.Attachment.DeviceIndex == '0'

            #                 group = {
            #                     GroupId : '@' + uid + '.resource.GroupId'
            #                     GroupName : '@' +  uid + '.resource.GroupName'
            #                 }

            #                 MC.canvas_data.component[ comp.uid ].resource.GroupSet.push group

            #                 return false
            #     else
            #         MC.canvas_data.component[parent].resource.SecurityGroupId.push '@'+uid+'.resource.GroupId'

            me.set 'sg_detail', sg_detail

        setSGName : ( uid, value ) ->

            old_name = MC.canvas_data.component[uid].resource.GroupName

            MC.canvas_data.component[uid].resource.GroupName = value

            MC.canvas_data.component[uid].name = value

            new_sg_detail = this.get 'sg_detail'

            new_sg_detail.component.name = value

            new_sg_detail.component.resource.GroupName = value

            this.set 'sg_detail', new_sg_detail

            _.map MC.canvas_property.sg_list, ( sg ) ->

                if sg.name == old_name

                    sg.name = value

                null

            null

        setSGDescription : ( uid, value ) ->

            MC.canvas_data.component[uid].resource.GroupDescription = value

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

    model = new SgModel()

    return model