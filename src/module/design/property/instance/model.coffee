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


        getHost  : ->
            console.log 'getHost'
            console.log this.get 'get_host'

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

                        if MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress

                            sg_detail.rules = MC.canvas_data.component[sg_uid].resource.IpPermissions.length + MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress.length
                        else

                            sg_detail.rules = MC.canvas_data.component[sg_uid].resource.IpPermissions.length

                        sg_detail.name = MC.canvas_data.component[sg_uid].resource.GroupName
                        sg_detail.desc = MC.canvas_data.component[sg_uid].resource.GroupDescription

                        instance_sg.detail.push sg_detail

            _.map MC.canvas_property.sg_list, (sg) ->
                
                if sg.uid not in sg_id_no_ref

                    tmp = {}

                    tmp.name = sg.name

                    tmp.uid = sg.uid

                    instance_sg.all_sg.push tmp

            instance_sg.total = instance_sg.detail.length

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
    }

    model = new InstanceModel()

    return model