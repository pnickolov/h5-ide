#############################
#  View Mode for design/property/stack
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC', 'constant' ], (Backbone, $, _, MC, constant) ->

    StackModel = Backbone.Model.extend {

        defaults :
            'property_detail'   : null
            'is_stack'          : null
            #'sg_display'        : null
            'network_acl'       : null
            'cost_list'         : null
            'type'              : 'stack'
            'total_fee'         : null

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

        getSGList : ->

            allComp = MC.canvas_data.component

            sgUIDAry = []

            return sgUIDAry

        addSubscription : ( data ) ->

            topic_uid = null

            existing = false

            $.each MC.canvas_data.component, ( comp_uid, comp ) ->

                if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic

                    topic_uid = comp_uid

                    existing = true

                    return false



            if not existing

                topic_comp = $.extend true, {}, MC.canvas.SNS_TOPIC_JSON.data

                topic_uid = MC.guid()

                topic_comp.name = topic_comp.resource.Name = topic_comp.resource.DisplayName = 'sns-topic'

                topic_comp.uid = topic_uid

                MC.canvas_data.component[topic_uid] = topic_comp

            if data.uid

                sub_comp = MC.canvas_data.component[data.uid]

                sub_comp.resource.Protocol = data.protocol

                sub_comp.resource.Endpoint = data.endpoint

            else
                sub_uid = MC.guid()

                sub_comp = $.extend true, {}, MC.canvas.SNS_SUB_JSON.data

                sub_comp.uid = sub_uid

                sub_comp.resource.Protocol = data.protocol

                sub_comp.resource.Endpoint = data.endpoint

                sub_comp.resource.TopicArn = '@' + topic_uid + '.resource.TopicArn'

                MC.canvas_data.component[sub_uid] = sub_comp

            sub_list = []

            has_asg = false

            $.each MC.canvas_data.component, ( comp_uid, comp ) ->

                if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription

                    tmp = {}

                    tmp.protocol = comp.resource.Protocol

                    tmp.endpoint = comp.resource.Endpoint

                    tmp.uid = comp.uid

                    sub_list.push tmp

                if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group

                    has_asg = true

                    null

            this.set 'subscription', sub_list
            this.set 'has_asg', has_asg
            null

        deleteSNS : ( uid ) ->

            delete MC.canvas_data.component[uid]

            null

        getSubscription : () ->

            sub_list = []

            has_asg = false

            $.each MC.canvas_data.component, ( comp_uid, comp ) ->

                if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription

                    tmp = {}

                    tmp.protocol = comp.resource.Protocol

                    tmp.endpoint = comp.resource.Endpoint

                    tmp.uid = comp.uid

                    sub_list.push tmp

                if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group

                    has_asg = true

                    null

            this.set 'subscription', sub_list

            this.set 'has_asg', has_asg

        getAppSubscription : () ->

            me = this
            topic_uid = null
            topic_arn = null
            snstopic = {}
            subscription = []
            $.each MC.canvas_data.component, ( comp_uid, comp ) ->

                if comp.type is constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic

                    topic_uid = comp_uid

                    topic_arn = comp.resource.TopicArn

                    snstopic.name = MC.data.resource_list[MC.canvas_data.region][topic_arn].Name

                    snstopic.arn = topic_arn

                    me.set 'snstopic', snstopic

                    return false

            if topic_arn

                $.each MC.data.resource_list[MC.canvas_data.region].Subscriptions, ( idx, sub )->

                    if sub.TopicArn is topic_arn

                        tmp = {}
                        tmp.protocol = sub.Protocol
                        tmp.endpoint = sub.Endpoint
                        tmp.arn = sub.SubscriptionArn

                        subscription.push tmp

            this.set 'subscription', subscription

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
                networkACLs.splice 0, 0, defaultACL[0]
            else
                defaultACL = networkACLs[ 0 ]

            this.set 'network_acl', networkACLs

            null

        getCost : ->
            me = this

            cost_list = []
            total_fee = 0

            region = MC.canvas_data.region
            feeMap = MC.data.config[region]

            #no config data load
            if not feeMap

                return false

            _.map MC.canvas_data.component, (item) ->
                uid = item.uid
                name = item.name

                if item.type is 'AWS.EC2.Instance'
                    size = item.resource.InstanceType
                    imageId = item.resource.ImageId

                    ami = v for k,v of feeMap.ami when v.imageId == imageId

                    if feeMap.ami[imageId]

                        if feeMap.ami[imageId].osType is 'win'
                            os = 'windows'
                        else
                            os = 'linux-other'

                        size_list = size.split('.')
                        fee = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].fee
                        unit = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].unit

                        cost_list.push { 'type' : item.type, 'resource' : name, 'size' : size, 'fee' : fee + '/hr' }

                        total_fee += fee * 24 * 30


                else if item.type is 'AWS.ELB'
                    elb = i for i in feeMap.price.elb when i.unit is 'perELBHour'

                    cost_list.push { 'type' : item.type, 'resource' : name, 'size' : '', 'fee' : elb.fee + '/hr' }

                    total_fee += elb.fee * 24 * 30

                else if item.type is 'AWS.EC2.EBS.Volume'
                    if item.resource.VolumeType is 'standard'
                        vol = i for i in feeMap.price.ebs.ebsVols when i.unit is 'perGBmoProvStorage'
                    else
                        vol = i for i in feeMap.price.ebs.ebsPIOPSVols when i.unit is 'perGBmoProvStorage'

                    cost_list.push { 'type' : item.type, 'resource' : name, 'size' : '', 'fee' : vol.fee + '/mo' }

                    total_fee += parseInt(vol.fee, 0)

                null

            # sort with type
            cost_list.sort (a, b) ->
                return if a.type <= b.type then 1 else -1
            me.set 'cost_list', cost_list

            if total_fee > 0 then me.set 'total_fee', parseFloat(total_fee).toFixed(2)

            me.trigger 'UPDATE_COST_LIST'

            null

    }

    model = new StackModel()

    return model
