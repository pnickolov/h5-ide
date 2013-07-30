#############################
#  View Mode for design/property/stack
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC', 'constant' ], (Backbone, $, _, MC, constant) ->

    StackModel = Backbone.Model.extend {

        defaults :
            'property_detail'   : null
            'is_stack'          : null
            'sg_display'        : null
            'network_acl'       : null
            'cost_list'         : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getProperty : ->
            me = this

            is_stack = true

            if MC.canvas_data.id.indexOf('app-') == 0
                is_stack = false

            property_detail = $.extend true, {}, MC.canvas_data
            property_detail.name = MC.canvas_data.name
            property_detail.region = constant.REGION_LABEL[MC.canvas_data.region]
            property_detail.type = me.getStackType()
            property_detail.is_vpc = true if property_detail.type and property_detail.type != 'EC2 Classic'

            if property_detail.is_vpc
                property_detail.acl_list = me.getNetworkACL()

            #property_detail.cost = me.getStackCost()

            me.set 'property_detail', property_detail
            me.set 'is_stack', is_stack

            me.getNetworkACL()

        getStackType : ->
            type = MC.canvas_data.platform

            if type == 'ec2-classic'
                return 'EC2 Classic'
            else if type == 'ec2-vpc'
                return 'EC2 VPC'
            else if type == 'default-vpc|custom-vpc'
                return 'Default VPC'
            else if type == 'custom-vpc'
                return 'Custom VPC'

        getSecurityGroup : ->
            me = this

            stack_sg = {}
            stack_sg.detail = []
            stack_sg.rules_detail_ingress = []
            stack_sg.rules_detail_egress = []

            _.map MC.canvas_property.sg_list, ( sg ) ->
                sg_detail = {}

                sg_detail.uid = sg.uid
                sg_detail.parent = sg.uid
                sg_detail.members = if 'member' in sg then sg.member.length else 0
                sg_detail.rules = MC.canvas_data.component[sg.uid].resource.IpPermissions.length + MC.canvas_data.component[sg.uid].resource.IpPermissionsEgress.length
                sg_detail.name = MC.canvas_data.component[sg.uid].resource.GroupName
                sg_detail.desc = MC.canvas_data.component[sg.uid].resource.GroupDescription

                stack_sg.rules_detail_ingress = stack_sg.rules_detail_ingress.concat MC.canvas_data.component[sg.uid].resource.IpPermissions
                stack_sg.rules_detail_egress = stack_sg.rules_detail_egress.concat MC.canvas_data.component[sg.uid].resource.IpPermissionsEgress

                stack_sg.detail.push sg_detail

            array_unique = ( ori_ary )->

                if ori_ary.length == 0
                    return []

                ary = ori_ary.slice 0
                tmp = []

                $.each ary, (idx, value)->
                    str = JSON.stringify value
                    if str not in tmp
                        tmp.push str
                    null

                return (JSON.parse item for item in tmp)


            stack_sg.rules_detail_ingress = array_unique stack_sg.rules_detail_ingress
            stack_sg.rules_detail_egress = array_unique stack_sg.rules_detail_egress

            me.set 'sg_display', stack_sg

        deleteSecurityGroup : (uid) ->
            me = this

            #delete sg from MC.canvas_property.sg_list
            $.each MC.canvas_property.sg_list, ( key, sg ) ->

                if sg and sg.uid == uid

                    #update instance
                    _.map sg.member, (iid) ->

                        sg_id_ref = "@"+uid+'.resource.GroupId'

                        sg_ids = MC.canvas_data.component[ iid ].resource.SecurityGroupId

                        if sg_ids.length != 1

                            MC.canvas_data.component[ iid ].resource.SecurityGroupId.splice sg_ids.indexOf sg_id_ref, 1

                    MC.canvas_property.sg_list.splice key, 1

                    delete MC.canvas_data.component[uid]

            null

        resetSecurityGroup : (uid) ->
            me = this

            property_detail = me.get 'property_detail'

            _.map property_detail.sg_list, (sg) ->
                if sg.uid == uid

                    flag = property_detail.sg_list[ property_detail.sg_list.indexOf sg ].is_shown
                    property_detail.sg_list[ property_detail.sg_list.indexOf sg ].is_shown = not flag

                    me.set 'property_detail', property_detail

            console.log me.get 'property_detail'

            null

        getNetworkACL : ->

            networkACLs = []

            ACL_TYPE = constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl

            linkToDefault = true
            defaultACLIdx = -1

            for id, component of MC.canvas_data.component
                if component.type == ACL_TYPE
                    acl =
                        uid    : component.uid
                        rule   : component.resource.EntrySet.length
                        name   : component.name
                        association : component.resource.AssociationSet.length
                        isUsed : false

                    if component.resource.AssociationSet.length isnt 0
                        acl.isUsed = true

                    if component.name == "DefaultACL"
                        acl.isUsed = true
                        defaultACLIdx = networkACLs.length

                    networkACLs.push acl

            if defaultACLIdx == -1
                console.log "[Warning] Cannot find DefaultACL!!!"

            if defaultACLIdx != 0
                defaultACL = networkACLs.splice defaultACLIdx, 1
                networkACLs.splice 0, 0, defaultACL
            else
                defaultACL = networkACLs[ 0 ]

            this.set 'network_acl', networkACLs

            null

        getStackCost : ->
            me = this

            cost_list = []
            total_fee = 0

            region = MC.canvas_data.region
            feeMap = MC.data.config[region]

            _.map MC.canvas_data.component, (item) ->
                uid = item.uid
                name = item.name

                if item.type is 'AWS.EC2.Instance'
                    size = item.resource.InstanceType
                    imageId = item.resource.ImageId

                    fee = ''
                    unit = ''

                    ami = null
                    ami = i for i in feeMap.ami when i.imageId == imageId

                    _.map feeMap.ami, (ami) ->
                        if ami.imageId == imageId
                            os = ''
                            if feeMap.ami[imageId].osType is 'win'
                                os = 'windows'
                            else
                                os = 'linux-other'

                            size_list = size.split('.')
                            fee = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].fee
                            unit = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].unit

                            cost_list.push { 'type' : item.type, 'resource' : name, 'size' : size, 'fee' : fee + '/' + unit }

                #else if item.type is 'AWS.ELB'
                #    fee = feeMap.price.elb

                #    cost_list.push { 'type' : item.type, 'resource' : name, 'size' : '', 'fee' : fee }

                #else if item.type is 'AWS.EC2.EBS.Volume'
                #    fee = feeMap.price.ebs.ebsVols

                #    cost_list.push { 'type' : item.type, 'resource' : name, 'size' : '', 'fee' : fee }

                null

            me.set 'cost_list', cost_list

            null

    }

    model = new StackModel()

    return model