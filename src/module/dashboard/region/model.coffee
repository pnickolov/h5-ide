#############################
#  View Mode for dashboard(region)
#############################

define [ 'backbone', 'jquery', 'underscore', 'aws_model', 'vpc_model',  'constant' ], (Backbone, $, _, aws_model, vpc_model, constant) ->

    current_region  = null
    resource_source = null
    vpc_attrs_value = null
    unmanaged_list  = null

    update_timestamp = 0

    popup_key_set = {
        "unmanaged_bubble" : {
            "DescribeVolumes": {
                "status": "status",
                "title": "volumeId",
                "sub_info":[
                    { "key": [ "createTime" ], "show_key": "Create Time"},
                    { "key": [ "availabilityZone" ], "show_key": "AZ"},
                    { "key": [ "attachmentSet", "item", "status" ], "show_key": "Attachment Status"}
                ]},
            "DescribeInstances": {},
            "DescribeVpnConnections": {},
            "DescribeVpcs": {}
        },
        "detail" : {
            "DescribeVolumes": {
                "title": "volumeId",
                "sub_info":[
                    { "key": [ "volumeId" ], "show_key": "Volume ID"},
                    { "key": [ "attachmentSet", "item", "device"  ], "show_key": "Device Name"},
                    { "key": [ "snapshotId" ], "show_key": "Snapshot ID"},
                    { "key": [ "createTime" ], "show_key": "Create Time"},
                    { "key": [ "attachmentSet", "item", "attachTime"  ], "show_key": "Attach Name"},
                    { "key": [ "attachmentSet", "item", "deleteOnTermination" ], "show_key": "Delete On Termination"},
                    { "key": [ "attachmentSet", "item", "instanceId" ], "show_key": "Instance ID"},
                    { "key": [ "status" ], "show_key": "status"},
                    { "key": [ "attachmentSet", "item", "status" ], "show_key": "Attachment Status"},
                    { "key": [ "availabilityZone" ], "show_key": "Availability Zone"},
                    { "key": [ "volumeType" ], "show_key": "Volume Type"},
                    { "key": [ "Iops" ], "show_key": "Iops"}
                ]},
            "DescribeInstances": {},
            "DescribeVpnConnections": {},
            "DescribeVpcs": {}
        }
    }

    #private
    RegionModel = Backbone.Model.extend {

        defaults :
            'resourse_list'         : null
            'vpc_attrs'             : null
            'unmanaged_list'        : null
            'status_list'           : null

        initialize : ->
            me = this

            aws_model.on 'AWS_RESOURCE_RETURN', ( result ) ->

                console.log 'AWS_RESOURCE_RETURN'

                resource_source = result.resolved_data[current_region]

                me.setResource resource_source
                me.updateUnmanagedList()

                null


            null

        #temp
        temp : ->
            me = this
            null

        #unmanaged_list
        updateUnmanagedList : ()->


            me = this

            time_stamp = new Date().getTime() / 1000
            unmanaged_list = {}
            unmanaged_list.time_stamp = time_stamp

            unmanaged_list.items = []
            resources_keys       = [ 'DescribeVolumes', 'DescribeLoadBalancers', 'DescribeInstances', 'DescribeVpnConnections', 'DescribeVpcs', 'DescribeAddresses' ]

            console.log resource_source
            _.map resources_keys, ( value ) ->
                cur_attr = resource_source[ value ]

                cur_tag = value

                _.map cur_attr, ( value ) ->
                    if me.hasnotTagId value.tagSet
                        name = if value.tagSet then value.tagSet.name else null
                        switch cur_tag
                            when "DescribeVolumes"
                                unmanaged_list.items.push { 'type': "Volume", 'name': (if name then name else value.volumeId), 'status': value.status, 'cost': 0.00, 'data-bubble-data': ( me.parseSourceValue cur_tag, value, "unmanaged_bubble", name ), 'data-modal-data': ( me.parseSourceValue cur_tag, value, "detail", name) }
                            when "DescribeInstances"
                                unmanaged_list.items.push { 'type': "Instance", 'name': (if name then name else value.instanceId), 'status': value.instanceState.name, 'cost': 0.00, 'data-modal-data': '' }
                            when "DescribeVpnConnections"
                                unmanaged_list.items.push { 'type': "VPN", 'name': (if name then name else value.vpnConnectionId), 'status': value.state, 'cost': 0.00, 'data-modal-data': '' }
                            when "DescribeVpcs"
                                unmanaged_list.items.push { 'type': "VPC", 'name': (if name then name else value.vpcId), 'status': value.state, 'cost': 0.00, 'data-modal-data': '' }
                            else
                    null
                null

            me.set 'unmanaged_list', unmanaged_list

            null

        #vpc_attrs
        describeRegionAccountAttributesService : ( region )->

            me = this

            current_region = region

            vpc_model.DescribeAccountAttributes { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), current_region,  ["supported-platforms"]

            vpc_model.once 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', ( result ) ->

                console.log 'region_VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'

                regionAttrSet = result.resolved_data.accountAttributeSet.item.attributeValueSet.item
                if $.type(regionAttrSet) == "array"
                    vpc_attrs_value = { 'classic' : 'Classic', 'vpc' : 'VPC' }
                else
                    vpc_attrs_value = { 'vpc' : 'VPC' }

                me.set 'vpc_attrs', vpc_attrs_value

                null

            null

        #if an array tagset has tagid
        hasnotTagId : ( tagset )->
            if tagset
                 _.map tagset, ( value ) ->
                    if value.key is "app-id" && value.value
                        false
            true

        #parse bubble value or detail value for unmanagedSource
        parseSourceValue : ( type, value, keys, name )->
            keys_to_parse  = null
            value_to_parse = value
            parse_result   = ''
            parse_sub_info = ''


            keys_type = keys
            if popup_key_set[keys]
                keys_to_parse = popup_key_set[keys][type]
            else
                keys_to_parse = popup_key_set['unmanaged_bubble'][type]

            if keys_to_parse.status && value_to_parse[ keys_to_parse.status ]
                parse_result += '"status":"' + value_to_parse[ keys_to_parse.status ] + '", '

            if keys_to_parse.title
                if keys is 'unmanaged_bubble' or 'bubble'
                    if name
                        parse_result += '"title":"' + name
                        if value_to_parse[ keys_to_parse.title ]
                            parse_result += '-' + value_to_parse[ keys_to_parse.title ]
                            parse_result += '", '
                    else
                        if value_to_parse[ keys_to_parse.title ]
                            parse_result += '"title":"'
                            parse_result += value_to_parse[ keys_to_parse.title ]
                            parse_result += '", '
                else if keys is 'detail'
                    if name
                        parse_result += '"title":"' + name
                        if value_to_parse[ keys_to_parse.title ]
                            parse_result += '(' + value_to_parse[ keys_to_parse.title ]
                            parse_result += ')", '
                    else
                        if value_to_parse[ keys_to_parse.title ]
                            parse_result += '"title":"'
                            parse_result += value_to_parse[ keys_to_parse.title ]
                            parse_result += '", '


            _.map keys_to_parse.sub_info, ( value ) ->
                key_array = value.key
                show_key  = value.show_key
                cur_key   = key_array[0]
                cur_value = value_to_parse[ cur_key ]

                _.map key_array, ( value, key ) ->
                    if cur_value
                        if key > 0
                            cur_value = cur_value.value
                            cur_value

                if cur_value
                    parse_sub_info += ( '"<dt>' + show_key + ': </dt><dd>' + cur_value + '</dd>", ')

                null

            if parse_sub_info
                parse_sub_info = '"sub_info":[' + parse_sub_info
                parse_sub_info = parse_sub_info.substring 0, parse_sub_info.length - 2
                parse_sub_info += ']'

            if parse_result
                parse_result = '{' + parse_result
                if parse_sub_info
                    parse_result += parse_sub_info
                else
                    parse_result = parse_result.substring 0, parse_result.length - 2
                parse_result += '}'

            console.log parse_result

            parse_result


        setResource : ( resources ) ->

            lists = {}

            elb = resources.DescribeLoadBalancers.LoadBalancerDescriptions

            if $.isEmptyObject elb then lists.ELB = 0 else if  elb.member.constructor == Array then lists.ELB = elb.member.length else lists.ELB = 1



            console.error lists


        describeAWSResourcesService : ( region )->

            me = this

            current_region = region

            resources = [
                constant.AWS_RESOURCE.INSTANCE
                constant.AWS_RESOURCE.EIP
                constant.AWS_RESOURCE.VOLUME
                constant.AWS_RESOURCE.VPC
                constant.AWS_RESOURCE.VPN
                constant.AWS_RESOURCE.ELB
            ]

            aws_model.resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region,  resources

        describeAWSStatusService : ( region )->
            console.log 'AWS_STATUS_RETURN'

            me = this

            current_region = region

            aws_model.status { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, null
            aws_model.once 'AWS_STATUS_RETURN', ( result ) ->

                console.log 'AWS_STATUS_RETURN'

                console.log result

                me.set 'status_list', ''

                null
    }

    model = new RegionModel()

    return model