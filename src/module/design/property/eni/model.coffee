#############################
#  View Mode for design/property/eni
#############################

define [ 'constant','backbone', 'jquery', 'underscore', 'MC' ], ( constant ) ->

    ENIModel = Backbone.Model.extend {

        defaults :
            'sg_display'     : null
            'eni_display'    : null
            'uid'            : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getENIDisplay : ( uid ) ->

            # The uid can be a line
            if MC.canvas_data.layout.connection[ uid ]
                this.set "eni_display", { name : "Instance-ENI Attachment" }
                connection = MC.canvas_data.layout.connection[ uid ]
                instance_id = null
                eni_id = null
                for uid, value of connection.target
                    if value is "eni-attach"
                        eni_id = uid
                    else
                        instance_id = uid

                this.set "association", {
                    eni : MC.canvas_data.component[eni_id].name
                    instance : MC.canvas_data.component[instance_id].name
                }
                return
            else
                this.set "association", null

            me = this

            eni_component = $.extend true, {}, MC.canvas_data.component[uid]

            if eni_component.resource.SourceDestCheck == 'true' or eni_component.resource.SourceDestCheck == true then eni_component.resource.SourceDestCheck = true else eni_component.resource.SourceDestCheck = false

            $.each eni_component.resource.PrivateIpAddressSet, ( idx, ip_detail) ->

                ip_ref = '@' + uid + '.resource.PrivateIpAddressSet.' + idx + '.PrivateIpAddress'

                ip_detail.index = idx

                $.each MC.canvas_data.component, ( comp_uid, comp ) ->

                    if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.PrivateIpAddress == ip_ref

                        ip_detail.has_eip = true

                        return false

            me.set 'eni_display', eni_component

            eni_sg = {}

            eni_sg.detail = []

            eni_sg.all_sg = []

            eni_sg.rules_detail_ingress = []

            eni_sg.rules_detail_egress = []

            sg_ids = (g.GroupId for g in MC.canvas_data.component[ uid ].resource.GroupSet)

            sg_id_no_ref = []

            _.map sg_ids, ( sg_id ) ->

                sg_uid = (sg_id.split ".")[0][1...]

                sg_id_no_ref.push sg_uid

                _.map MC.canvas_property.sg_list, ( value, key ) ->

                    if value.uid == sg_uid

                        sg_detail = {}

                        sg_detail.uid = sg_uid

                        sg_detail.parent = uid

                        sg_detail.members = value.member.length

                        sg_detail.rules = MC.canvas_data.component[sg_uid].resource.IpPermissions.length + MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress.length

                        sg_detail.name = MC.canvas_data.component[sg_uid].resource.GroupName

                        sg_detail.desc = MC.canvas_data.component[sg_uid].resource.GroupDescription

                        eni_sg.rules_detail_ingress = eni_sg.rules_detail_ingress.concat MC.canvas_data.component[sg_uid].resource.IpPermissions

                        eni_sg.rules_detail_egress = eni_sg.rules_detail_egress.concat MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress

                        eni_sg.detail.push sg_detail

            _.map MC.canvas_property.sg_list, (sg) ->

                if sg.uid not in sg_id_no_ref

                    tmp = {}

                    tmp.name = sg.name

                    tmp.uid = sg.uid

                    eni_sg.all_sg.push tmp

            eni_sg.total = eni_sg.detail.length

            array_unique = ( origin_ary )->

                if origin_ary.length == 0

                    return []

                ary = origin_ary.slice 0


                $.each ary, (idx, value)->

                    ary[idx] = JSON.stringify value

                    null

                ary.sort()

                tmp = [ary[0]]

                _.map ary, ( val, i ) ->

                    if val != tmp[tmp.length - 1]

                        tmp.push(val)



                return (JSON.parse node for node in tmp)


            eni_sg.rules_detail_ingress = array_unique eni_sg.rules_detail_ingress
            eni_sg.rules_detail_egress = array_unique eni_sg.rules_detail_egress

            me.set 'sg_display', eni_sg

        setEniDesc : ( uid , value ) ->

            MC.canvas_data.component[uid].resource.Description = value

            null

        setSourceDestCheck : ( uid, value ) ->

            MC.canvas_data.component[uid].resource.SourceDestCheck = value

            null

        getSGList : () ->

            uid = this.get 'uid'
            sgAry = MC.canvas_data.component[uid].resource.GroupSet

            sgUIDAry = []
            _.each sgAry, (value) ->
                sgUID = value.GroupId.slice(1).split('.')[0]
                sgUIDAry.push sgUID
                null

            return sgUIDAry

        unAssignSGToComp : (sg_uid) ->

            eniUID = this.get 'uid'

            originSGAry = MC.canvas_data.component[eniUID].resource.GroupSet

            currentSG = '@' + sg_uid + '.resource.GroupName'
            currentSGId = '@' + sg_uid + '.resource.GroupId'

            originSGAry = _.filter originSGAry, (value) ->
                value.GroupId isnt currentSGId

            MC.canvas_data.component[eniUID].resource.GroupSet = originSGAry

            null

        assignSGToComp : (sg_uid) ->

            eniUID = this.get 'uid'

            originSGAry = MC.canvas_data.component[eniUID].resource.GroupSet

            currentSG = '@' + sg_uid + '.resource.GroupName'
            currentSGId = '@' + sg_uid + '.resource.GroupId'

            isInGroup = false

            _.each originSGAry, (value) ->
                if value.GroupId is currentSGId
                    isInGroup = true
                null

            if !isInGroup
                originSGAry.push {
                    GroupName: currentSG
                    GroupId: currentSGId
                }

            MC.canvas_data.component[eniUID].resource.GroupSet = originSGAry

            null

        addNewIP : ( eni_uid ) ->


            ip_detail = {
                "Association" : {
                        "AssociationID": ""
                        "PublicDnsName": ""
                        "AllocationID": ""
                        "InstanceId": ""
                        "IpOwnerId": ""
                        "PublicIp": ""
                    }
                "PrivateIpAddress": "10.0.0.1"
                "AutoAssign": "false"
                "Primary": "false"
            }
            MC.canvas_data.component[eni_uid].resource.PrivateIpAddressSet.push ip_detail

        attachEIP : ( eni_uid, eip_index, attach ) ->

            if attach

                eip_component = $.extend true, {}, MC.canvas.EIP_JSON.data

                eip_uid = MC.guid()

                eip_component.uid = eip_uid

                eip_component.resource.PrivateIpAddress = '@' + eni_uid + '.resource.PrivateIpAddressSet.' + eip_index + '.PrivateIpAddress'

                eip_component.resource.NetworkInterfaceId = '@' +  eni_uid + '.resource.NetworkInterfaceId'

                eip_component.resource.Domain = 'vpc'

                data = MC.canvas.data.get('component')

                data[eip_uid] = eip_component

                MC.canvas.data.set('component', data)

                MC.canvas.update eni_uid,'image','eip_status', MC.canvas.IMAGE.EIP_ON

            else

                ip_ref = '@' + eni_uid + '.resource.PrivateIpAddressSet.' + eip_index + '.PrivateIpAddress'

                $.each MC.canvas_data.component, ( comp_uid, comp ) ->

                    if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.PrivateIpAddress == ip_ref

                        delete MC.canvas_data.component[comp_uid]

                        #determine whether all eip are detach

                        existing = false

                        $.each MC.canvas_data.component, ( k, v ) ->

                            if v.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and v.resource.NetworkInterfaceId == '@' +  eni_uid + '.resource.NetworkInterfaceId'

                                existing = true

                                return false

                        if not existing

                            MC.canvas.update eni_uid,'image','eip_status', MC.canvas.IMAGE.EIP_OFF

        removeIP : ( eni_uid, index ) ->

            ip_ref = '@' + eni_uid + '.resource.PrivateIpAddressSet.' + index + '.PrivateIpAddress'

            eni_ref = '@' + eni_uid + '.resource.NetworkInterfaceId'

            max_index = MC.canvas_data.component[eni_uid].resource.PrivateIpAddressSet.length - 1

            modify_index_refs = []

            min_index = index + 1

            $.each [min_index..max_index], ( i, index_value ) ->

                modify_index_refs.push '@' + eni_uid + '.resource.PrivateIpAddressSet.' + index_value + '.PrivateIpAddress'

            MC.canvas_data.component[eni_uid].resource.PrivateIpAddressSet.splice index, 1

            remove_uid = null

            $.each MC.canvas_data.component, ( k, v ) ->

                if v.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and v.resource.NetworkInterfaceId == eni_ref

                    if v.resource.PrivateIpAddress in modify_index_refs

                        v.resource.PrivateIpAddress = '@' + eni_uid + '.resource.PrivateIpAddressSet.' + (parseInt(v.resource.PrivateIpAddress.split('.')[3],10)-1) + '.PrivateIpAddress'

                    if v.resource.PrivateIpAddress == ip_ref

                        remove_uid = v.uid

                    null

            delete MC.canvas_data.component[remove_uid]

        setIPList : (inputIPAry) ->

            # get all other ip in cidr
            eniUID = this.get 'uid'

            realIPAry = MC.aws.eni.generateIPList eniUID, inputIPAry

            MC.aws.eni.saveIPList eniUID, realIPAry

    }

    model = new ENIModel()

    return model
