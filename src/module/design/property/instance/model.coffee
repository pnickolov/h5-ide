#############################
#  View Mode for design/property/instance
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], (constant) ->

    InstanceModel = Backbone.Model.extend {

        defaults :
            'uid'         : null
            'name'        : null
            'update_instance_title' : null

        listen : ->
            #listen
            this.listenTo this, 'change:name', this.setName

        getUID  : ( uid ) ->
            console.log 'getUID'
            this.set 'get_uid', MC.canvas_data.component[ uid ].uid
            null

        setName  : () ->
            console.log 'setName'
            MC.canvas_data.component[ this.get( 'get_uid' )].name = this.get 'name'
            this.set 'update_instance_title', this.get 'name'
            null

        getName  : () ->
            console.log 'getName'
            this.set 'name', MC.canvas_data.component[ this.get( 'get_uid' )].name
            null

        setInstanceType  : ( uid, value ) ->

            console.log 'setInstanceType = ' + value

            type_ary = value.split '.'

            eni_number = 0

            $.each MC.canvas_data.component, (index, comp) ->

                if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId.split('.')[0][1...] == uid

                    eni_number += 1

            max_eni_num = MC.data.config[MC.canvas_data.component[uid].resource.Placement.AvailabilityZone[0...-1]].instance_type[type_ary[0]][type_ary[1]].eni

            if eni_number > 2 and eni_number > max_eni_num

                this.trigger 'EXCEED_ENI_LIMIT', uid, value, max_eni_num

            else
                
                MC.canvas_data.component[ uid ].resource.InstanceType = value

            null
            #this.set 'set_host', 'host'

        setEbsOptimized : ( uid, value )->

            console.log 'setEbsOptimized = ' + value

            MC.canvas_data.component[ uid ].resource.EbsOptimized = value

            null

        setTenancy : ( uid, value ) ->

            console.log 'setTenancy = ' + value

            MC.canvas_data.component[ uid ].resource.Placement.Tenancy = value

            null

        setCloudWatch : ( uid, value ) ->

            console.log 'setCloudWatch = ' + value

            if value

                MC.canvas_data.component[ uid ].resource.Monitoring = 'enabled'

            else
                MC.canvas_data.component[ uid ].resource.Monitoring = 'disabled'


            null

        setUserData : ( uid, value ) ->

            console.log 'setUserData = ' + value

            MC.canvas_data.component[ uid ].resource.UserData.Data = value

            null
        
        setBase64Encoded : ( uid, value )->

            console.log 'setBase64Encoded = ' + value

            MC.canvas_data.component[ uid ].resource.UserData.Base64Encoded = value

            null

        setEniDescription: ( uid, value ) ->

            console.log 'setEniDescription = ' + value

            _.map MC.canvas_data.component, ( val, key ) ->

                if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

                    val.resource.Description = value

                null

            null

        setSourceCheck : ( uid, value ) ->

            console.log 'setSourceCheck = ' + value

            _.map MC.canvas_data.component, ( val, key ) ->

                if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

                    val.resource.SourceDestCheck = value

                null

            null

        setKP : ( uid, kp_name ) ->

            _.map MC.canvas_property.kp_list, ( kp ) ->

                if kp[kp_name]

                    kp_ref = '@' + kp[kp_name] + '.resource.KeyName'

                    console.log 'setKP = ' + kp_ref

                    MC.canvas_data.component[ uid ].resource.KeyName = kp_ref

                null

            null

        addKP : ( uid, kp_name ) ->

            component_data = $.extend(true, {}, MC.canvas.KP_JSON.data)

            kp_uid = MC.guid()
            component_data.uid = kp_uid
            component_data.resource.KeyName = kp_name
            component_data.name = kp_name

            kp_ref = '@' + kp_uid + '.resource.KeyName'

            console.log 'addKP = ' + kp_ref

            MC.canvas_data.component[ uid ].resource.KeyName = kp_ref

            data = MC.canvas.data.get 'component'

            data[kp_uid] = component_data

            MC.canvas.data.set 'component', data

            tmp = {}

            tmp[kp_name] = kp_uid

            MC.canvas_property.kp_list.push tmp

            null

        addSGtoInstance : (instance_uid, sg_uid) ->

            if MC.canvas_data.platform != MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

                $.each MC.canvas_data.component, ( key, comp ) ->

                    if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId.split('.')[0][1...] == instance_uid and comp.resource.Attachment.DeviceIndex == '0'

                        group = {
                            GroupId : '@' + sg_uid + '.resource.GroupId'
                            GroupName : '@' +  sg_uid + '.resource.GroupName'
                        }

                        MC.canvas_data.component[ comp.uid ].resource.GroupSet.push group

                        return false
            else
                MC.canvas_data.component[ instance_uid ].resource.SecurityGroupId.push '@' + sg_uid + '.resource.GroupId'

                _.map MC.canvas_property.sg_list, ( sg ) ->

                    if sg.uid == sg_uid

                        sg.member.push instance_uid

                    null

            null

        getCheckBox : ( uid ) ->

            checkbox = {}

            checkbox.ebsOptimized = true if MC.canvas_data.component[ uid ].resource.EbsOptimized == true or MC.canvas_data.component[ uid ].resource.EbsOptimized == 'true'

            checkbox.monitoring = true if MC.canvas_data.component[ uid ].resource.Monitoring == 'enabled'

            checkbox.base64Encoded = true if MC.canvas_data.component[ uid ].resource.UserData.Base64Encoded == true or MC.canvas_data.component[ uid ].resource.UserData.Base64Encoded == "true"

            checkbox.tenancy = true if MC.canvas_data.component[ uid ].resource.Placement.Tenancy == 'default' or MC.canvas_data.component[ uid ].resource.Placement.Tenancy == ''

            checkbox

        getEni : ( uid ) ->

            eni_detail = {}

            _.map MC.canvas_data.component, ( val, key ) ->

                if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

                    eni_detail.description = val.resource.Description

                    eni_detail.sourceCheck = true if val.resource.SourceDestCheck == 'true' or val.resource.SourceDestCheck == true

                null

            eni_detail


        getAmi : ( uid ) ->

            ami_id = MC.canvas_data.component[ uid ].resource.ImageId

            JSON.stringify MC.data.dict_ami[ami_id]

        getAmiDisp : ( uid ) ->

            disp = {}

            ami_id = MC.canvas_data.component[ uid ].resource.ImageId

            disp.name = MC.data.dict_ami[ami_id].name

            disp.icon = MC.data.dict_ami[ami_id].osType + '.' + MC.data.dict_ami[ami_id].architecture + '.' + MC.data.dict_ami[ami_id].rootDeviceType + ".png"

            disp

        getSgDisp : ( uid ) ->

            instance_sg = {}

            instance_sg.detail = []

            instance_sg.all_sg = []

            instance_sg.rules_detail_ingress = []

            instance_sg.rules_detail_egress = []

            sg_ids = null

            if MC.canvas_data.platform != MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

                $.each MC.canvas_data.component, ( key, comp ) ->

                    if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId.split('.')[0][1...] == uid and comp.resource.Attachment.DeviceIndex == '0'

                        sg_ids = (g.GroupId for g in MC.canvas_data.component[ comp.uid ].resource.GroupSet)

                        return false
            else
                sg_ids = MC.canvas_data.component[ uid ].resource.SecurityGroupId

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

                        instance_sg.rules_detail_ingress = instance_sg.rules_detail_ingress.concat MC.canvas_data.component[sg_uid].resource.IpPermissions

                        instance_sg.rules_detail_egress = instance_sg.rules_detail_egress.concat MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress

                        instance_sg.detail.push sg_detail

            _.map MC.canvas_property.sg_list, (sg) ->
                
                if sg.uid not in sg_id_no_ref

                    tmp = {}

                    tmp.name = sg.name

                    tmp.uid = sg.uid

                    instance_sg.all_sg.push tmp

            instance_sg.total = instance_sg.detail.length

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


            instance_sg.rules_detail_ingress = array_unique instance_sg.rules_detail_ingress
            instance_sg.rules_detail_egress = array_unique instance_sg.rules_detail_egress

            instance_sg


        getKerPair : (uid)->

            kp_list = []

            current_key_pair = MC.canvas_data.component[ uid ].resource.KeyName

            _.map MC.canvas_data.component, (value, key) ->

                if value.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair
                    kp = {}

                    kp.name = value.resource.KeyName
                    kp.uid = value.uid
                    
                    if MC.canvas_data.component[(current_key_pair.split ".")[0][1...]].resource.KeyName == value.resource.KeyName

                        kp.selected = true

                    kp_list.push kp

            kp_list

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

        removeSG : ( uid, sg_uid ) ->

            sg_id_ref = "@"+sg_uid+'.resource.GroupId'

            if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

                sg_ids = MC.canvas_data.component[ uid ].resource.SecurityGroupId

                if sg_ids.length != 1

                    sg_ids.splice sg_ids.indexOf sg_id_ref, 1

                    $.each MC.canvas_property.sg_list, ( key, value ) ->

                        if value.uid == sg_uid

                            index = value.member.indexOf uid

                            value.member.splice index, 1

                            # delete member 0 sg

                            if value.member.length == 0 and value.name != 'DefaultSG'

                                MC.canvas_property.sg_list.splice key, 1

                                delete MC.canvas_data.component[sg_uid]

                                $.each MC.canvas_data.component, ( key, comp ) ->

                                    if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

                                        $.each comp.resource.IpPermissions, ( i, rule ) ->

                                            if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg_uid

                                                MC.canvas_data.component[key].resource.IpPermissions.splice i, 1

                                        $.each comp.resource.IpPermissionsEgress, ( i, rule ) ->

                                            if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg_uid

                                                MC.canvas_data.component[key].resource.IpPermissionsEgress.splice i, 1

                            return false

            else

                $.each MC.canvas_data.component, ( key, comp ) ->

                    if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId.split('.')[0][1...] == uid and comp.resource.Attachment.DeviceIndex == '0'

                        if comp.GroupId.length != 1

                            $.each comp.GroupId, ( index, group) ->

                                if group.GroupId == sg_id_ref

                                    comp.GroupId.splice index, 1

                                    return false

                            $.each MC.canvas_property.sg_list, ( idx, value ) ->

                                if value.uid == sg_uid

                                    index = value.member.indexOf uid

                                    value.member.splice index, 1

                                    # delete member 0 sg

                                    if value.member.length == 0 and value.name != 'DefaultSG'

                                        MC.canvas_property.sg_list.splice idx, 1

                                        delete MC.canvas_data.component[sg_uid]

                                        $.each MC.canvas_data.component, ( key, comp ) ->

                                            if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

                                                $.each comp.resource.IpPermissions, ( i, rule ) ->

                                                    if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg_uid

                                                        MC.canvas_data.component[key].resource.IpPermissions.splice i, 1

                                                $.each comp.resource.IpPermissionsEgress, ( i, rule ) ->

                                                    if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg_uid

                                                        MC.canvas_data.component[key].resource.IpPermissionsEgress.splice i, 1
                        return false

            null


    }

    model = new InstanceModel()

    return model