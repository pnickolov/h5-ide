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
            'stack_state'       : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getProperty : ->
            me = this

            is_stack = true

            if MC.canvas.getState() is 'stack'
                me.set 'stack_state', true
            else
                me.set 'stack_state', false

            # if MC.canvas_data.id.indexOf('app-') == 0
            #     is_stack = false

            property_detail = $.extend true, {}, MC.canvas_data
            property_detail.name = MC.canvas_data.name
            property_detail.region = constant.REGION_SHORT_LABEL[MC.canvas_data.region]
            property_detail.type = me.getStackType()
            property_detail.is_vpc = true if property_detail.type and property_detail.type != 'EC2 Classic'

            if property_detail.is_vpc
                property_detail.acl_list = me.getNetworkACL()

            me.set 'property_detail', property_detail
            me.set 'is_stack', is_stack

            me.getNetworkACL()

        getStackType : ->

            type = ''

            switch MC.canvas_data.platform

                when 'ec2-classic'  then type = 'EC2 Classic'

                when 'ec2-vpc'      then type = 'EC2 VPC'

                when 'default-vpc'  then type = 'Default VPC'

                when 'custom-vpc'   then type = 'Custom VPC'

            #return
            type


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

            sub_list = this.get 'subscription'
            for sub, idx in sub_list
                if sub.uid is uid
                    sub_list.splice idx, 1
                    break

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

                if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration

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

                    topic_data = MC.data.resource_list[MC.canvas_data.region][topic_arn]

                    # The data is not prepared
                    if not topic_data
                        return false

                    snstopic.name = topic_data.Name
                    snstopic.arn  = topic_arn
                    me.set 'snstopic', snstopic

                    return false

            if topic_arn

                subs = MC.data.resource_list[MC.canvas_data.region].Subscriptions
                if subs
                    $.each subs, ( idx, sub )->

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
                        acl.isDefault = true
                        defaultACLIdx = networkACLs.length
                    else
                        acl.isDefault = false

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

            result = MC.aws.aws.getCost MC.canvas_data

            me.set 'cost_list', result.cost_list
            me.set 'total_fee', result.total_fee

            # cost_list = []
            # total_fee = 0

            # region = MC.canvas_data.region
            # feeMap = MC.data.config[region]

            # #no config data load
            # if not ( feeMap and feeMap.ami and feeMap.price )
            #     me.set 'cost_list', cost_list
            #     me.set 'total_fee', total_fee
            #     return false

            # _.map MC.canvas_data.component, (item) ->
            #     uid = item.uid
            #     name = item.name
            #     type = item.type

            #     # instance
            #     if item.type is 'AWS.EC2.Instance'
            #         size = item.resource.InstanceType
            #         imageId = item.resource.ImageId

            #         ami = v for k,v of feeMap.ami when v.imageId == imageId

            #         if 'ami' of feeMap and imageId of feeMap.ami

            #             if feeMap.ami[imageId].osType is 'win'
            #                 os = 'windows'
            #             else
            #                 os = 'linux-other'

            #             size_list = size.split('.')
            #             fee = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].fee
            #             unit = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].unit

            #             cost_list.push { 'resource' : name, 'size' : size, 'fee' : fee + (if unit is 'hour' then '/hr' else '/mo') }

            #             total_fee += fee * 24 * 30

            #             ## detail monitor
            #             if item.resource.Monitoring is 'enabled'

            #                 fee = 3.50
            #                 cost_list.push { 'resource' : name, 'type' : 'Detailed Monitoring', 'fee' : fee + '/mo' }
            #                 total_fee += fee

            #     # elb
            #     else if item.type is 'AWS.ELB'
            #         if 'price' of feeMap and 'elb' of feeMap.price
            #             elb = i for i in feeMap.price.elb when i.unit is 'perELBHour'

            #             cost_list.push { 'type' : type, 'resource' : name, 'fee' : elb.fee + '/hr' }

            #             total_fee += elb.fee * 24 * 30

            #     # volume
            #     else if item.type is 'AWS.EC2.EBS.Volume'
            #         if 'price' of feeMap and 'ebs' of feeMap.price
            #             if item.resource.VolumeType is 'standard'
            #                 vol = i for i in feeMap.price.ebs.ebsVols when i.unit is 'perGBmoProvStorage'
            #             else
            #                 vol = i for i in feeMap.price.ebs.ebsPIOPSVols when i.unit is 'perGBmoProvStorage'

            #             # get attached instanc name
            #             instance_uid    = item.resource.AttachmentSet.InstanceId.split('@')[1].split('.')[0]
            #             instance_name   = MC.canvas_data.component[instance_uid].name

            #             cost_list.push { 'resource' : instance_name + ' - ' + name, 'size' :  item.resource.Size + 'G', 'fee' : vol.fee + '/perGBmo' }

            #             total_fee += parseFloat(vol.fee * item.resource.Size)

            #     # asg
            #     else if item.type is 'AWS.AutoScaling.Group'
            #         cap = item.resource.DesiredCapacity

            #         config_uid = item.resource.LaunchConfigurationName.split('@')[1].split('.')[0]
            #         config = MC.canvas_data.component[config_uid]

            #         if config

            #             asg_price = 0

            #             imageId = config.resource.ImageId
            #             size    = config.resource.InstanceType

            #             ami = v for k,v of feeMap.ami when v.imageId == imageId

            #             if 'ami' of feeMap and imageId of feeMap.ami

            #                 if feeMap.ami[imageId].osType is 'win'
            #                     os = 'windows'
            #                 else
            #                     os = 'linux-other'

            #                 size_list = size.split('.')
            #                 fee = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].fee
            #                 unit = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].unit

            #                 if unit is 'hour'
            #                     asg_price += fee * 24 * 30
            #                 else
            #                     asg_price += fee

            #             if config.resource.BlockDeviceMapping
            #                 for block in config.resource.BlockDeviceMapping
            #                     vol = i for i in feeMap.price.ebs.ebsVols when i.unit is 'perGBmoProvStorage'
            #                     asg_price += block.Ebs.VolumeSize * vol.fee

            #             if asg_price > 0

            #                 cost_list.push {'resource' : name, 'size' : cap, 'fee' : asg_price.toFixed(3) + '/mo'}
            #                 total_fee += asg_price * cap

            #             ## detail monitor
            #             if config.resource.InstanceMonitoring is 'enabled'

            #                 fee = 3.50
            #                 cost_list.push { 'resource' : name, 'type' : 'Detailed Monitoring', 'fee' : fee + '/mo' }
            #                 total_fee += fee

            #     ## alarm
            #     else if item.type is 'AWS.CloudWatch.CloudWatch'
            #         period = parseInt(item.resource.Period, 10)
            #         if period and period <= 300
            #             fee = 0.10
            #             cost_list.push {'resource' : name, 'size' : '', 'fee' : fee + '/mo'}
            #             total_fee += fee

            #     null

            # # sort with type
            # cost_list.sort (a, b) ->
            #     return if a.type <= b.type then 1 else -1
            # me.set 'cost_list', cost_list

            # if total_fee > 0 then me.set 'total_fee', parseFloat(total_fee).toFixed(2)

            # me.trigger 'UPDATE_COST_LIST'

            null

    }

    model = new StackModel()

    return model
