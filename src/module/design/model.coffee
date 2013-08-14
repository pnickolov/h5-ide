#############################
#  View Mode for design
#############################

define [ 'MC', 'event', 'app_model', 'backbone' ], ( MC, ide_event, app_model ) ->

    #private
    DesignModel = Backbone.Model.extend {

        defaults :
            snapshot : null

        saveTab : ( tab_id, snapshot, data, property, property_panel, last_open_property ) ->
            console.log 'saveTab'
            MC.tab[ tab_id ] = { 'snapshot' : snapshot, 'data' : data, 'property' : property, 'property_panel' : property_panel, 'last_open_property' : last_open_property }
            null

        saveProcessTab : ( tab_id ) ->
            if !MC.tab[ tab_id ]     then MC.tab[ tab_id ] = MC.process[ tab_id ]
            #if MC.process[ tab_id ] then delete MC.process[ tab_id ]
            null

        readTab : ( type, tab_id ) ->
            console.log 'readTab'
            #set snapshot|data vo
            if MC.tab[ tab_id ].snapshot is this.get 'snapshot' then this.set 'snapshot', null
            #
            this.set 'snapshot',      MC.tab[ tab_id ].snapshot
            #
            this.setCanvasData        MC.tab[ tab_id ].data
            #
            this.setCanvasProperty    MC.tab[ tab_id ].property
            #
            this.setPropertyPanel     MC.tab[ tab_id ].property_panel
            #
            this.setLastOpenProperty  MC.tab[ tab_id ].last_open_property, tab_id
            null

        updateTab : ( old_tab_id, tab_id ) ->
            console.log 'updateTab'
            if MC.tab[ old_tab_id ] is undefined then return
            #
            MC.tab[ tab_id ] = { 'snapshot' : MC.tab[ old_tab_id ].snapshot, 'data' : MC.tab[ old_tab_id ].data, 'property' : MC.tab[ old_tab_id ].property }
            #
            this.deleteTab old_tab_id

        deleteTab    : ( tab_id ) ->
            console.log 'deleteTab'
            delete MC.tab[ tab_id ]
            console.log MC.tab
            #
            if MC.process[ tab_id ] then delete MC.process[ tab_id ]
            null

        setCanvasData : ( data ) ->
            console.log 'setCanvasData'
            MC.canvas_data = data
            null

        getCanvasData : () ->
            console.log 'getCanvasData'
            MC.canvas_data

        setCanvasProperty : ( property ) ->
            console.log 'setCanvasProperty'
            MC.canvas_property = property
            null

        getCanvasProperty : () ->
            console.log 'getCanvasProperty'
            MC.canvas_property

        setPropertyPanel : ( property_panel ) ->
            console.log 'setPropertyPanel'
            MC.data.current_sub_main = property_panel
            null

        getPropertyPanel : () ->
            console.log 'getPropertyPanel'
            #temp
            MC.data.current_sub_main.unLoadModule()
            #
            MC.data.current_sub_main

        setLastOpenProperty : ( last_open_property, tab_id ) ->
            console.log 'setLastOpenProperty, tab_id = ' + tab_id
            console.log tab_id.indexOf( 'app' )
            if tab_id.indexOf( 'app' ) isnt -1 then tab_type = 'OPEN_APP' else tab_type = 'OPEN_STACK'
            #
            MC.data.last_open_property = last_open_property
            #temp
            if !MC.data.last_open_property
                MC.data.last_open_property = { 'event_type' : ide_event.OPEN_PROPERTY, 'type' : 'component', 'uid' : '', 'instance_expended_id' : '', 'tab_type' : tab_type }
            #
            if MC.data.last_open_property.event_type is 'OPEN_PROPERTY'
                ide_event.trigger MC.data.last_open_property.event_type, MC.data.last_open_property.type, MC.data.last_open_property.uid, MC.data.last_open_property.instance_expended_id, this.get( 'snapshot' ).property, tab_type
            null

        getLastOpenProperty : () ->
            console.log 'getLastOpenProperty'
            MC.data.last_open_property



        _cacheResource : (resources, region) ->

            #cache aws resource data to MC.data.reosurce_list

            #vpc
            if resources.DescribeVpcs
                _.map resources.DescribeVpcs, ( res, i ) ->
                    MC.data.resource_list[region][res.vpcId] = res
                    null

            #instance
            if resources.DescribeInstances
                _.map resources.DescribeInstances, ( res, i ) ->
                    MC.data.resource_list[region][res.instanceId] = res
                    null

            #volume
            if resources.DescribeVolumes
                _.map resources.DescribeVolumes, ( res, i ) ->
                    MC.data.resource_list[region][res.volumeId] = res
                    null

            #eip
            if resources.DescribeAddresses
                _.map resources.DescribeAddresses, ( res, i ) ->
                    MC.data.resource_list[region][res.publicIp] = res
                    null

            #elb
            if resources.DescribeLoadBalancers
                _.map resources.DescribeLoadBalancers, ( res, i ) ->
                    MC.data.resource_list[region][res.LoadBalancerName] = res
                    null

            #vpn
            if resources.DescribeVpnConnections
                _.map resources.DescribeVpnConnections, ( res, i ) ->
                    MC.data.resource_list[region][res.vpnConnectionId] = res
                    null

            #kp
            if resources.DescribeKeyPairs
                _.map resources.DescribeKeyPairs.item, ( res, i ) ->
                    MC.data.resource_list[region][res.keyFingerprint] = res
                    null

            #sg
            if resources.DescribeSecurityGroups
                _.map resources.DescribeSecurityGroups.item, ( res, i ) ->
                    MC.data.resource_list[region][res.groupId] = res
                    null

            #dhcp
            if resources.DescribeDhcpOptions
                _.map resources.DescribeDhcpOptions.item, ( res, i ) ->
                    MC.data.resource_list[region][res.dhcpOptionsId] = res
                    null

            #subnet
            if resources.DescribeSubnets
                _.map resources.DescribeSubnets.item, ( res, i ) ->
                    MC.data.resource_list[region][res.subnetId] = res
                    null

            #routetable
            if resources.DescribeRouteTables
                _.map resources.DescribeRouteTables.item, ( res, i ) ->
                    MC.data.resource_list[region][res.routeTableId] = res
                    null

            #acl
            if resources.DescribeNetworkAcls
                _.map resources.DescribeNetworkAcls.item, ( res, i ) ->
                    MC.data.resource_list[region][res.networkAclId] = res
                    null

            #eni
            if resources.DescribeNetworkInterfaces
                _.map resources.DescribeNetworkInterfaces.item, ( res, i ) ->
                    MC.data.resource_list[region][res.networkInterfaceId] = res
                    null

            #igw
            if resources.DescribeInternetGateways
                _.map resources.DescribeInternetGateways.item, ( res, i ) ->
                    MC.data.resource_list[region][res.internetGatewayId] = res
                    null

            #vgw
            if resources.DescribeVpnGateways
                _.map resources.DescribeVpnGateways.item, ( res, i ) ->
                    MC.data.resource_list[region][res.vpnGatewayId] = res
                    null

            #cgw
            if resources.DescribeCustomerGateways
                _.map resources.DescribeCustomerGateways.item, ( res, i ) ->
                    MC.data.resource_list[region][res.customerGatewayId] = res
                    null

            ########################

            #asg
            if resources.DescribeAutoScalingGroups
                _.map resources.DescribeAutoScalingGroups.member, ( res, i ) ->
                    MC.data.resource_list[region][res.AutoScalingGroupARN] = res
                    null

            #asg instance
            if resources.DescribeAutoScalingInstances
                _.map resources.DescribeAutoScalingInstances.member, ( res, i ) ->
                    MC.data.resource_list[region][res.InstanceId] = res
                    null

            #asl lc
            if resources.DescribeLaunchConfigurations
                _.map resources.DescribeLaunchConfigurations.member, ( res, i ) ->
                    MC.data.resource_list[region][res.LaunchConfigurationARN] = res
                    null

            #asl nc
            if resources.DescribeNotificationConfigurations

                #init
                if !MC.data.resource_list[region].NotificationConfigurations
                    MC.data.resource_list[region].NotificationConfigurations = []

                _.map resources.DescribeNotificationConfigurations.member, ( res, i ) ->
                    MC.data.resource_list[region].NotificationConfigurations.push res
                    null

            #asl sp
            if resources.DescribePolicies
                _.map resources.DescribePolicies.member, ( res, i ) ->
                    MC.data.resource_list[region][res.PolicyARN] = res
                    null

            #asl sa
            if resources.DescribeScheduledActions
                _.map resources.DescribeScheduledActions.member, ( res, i ) ->
                    MC.data.resource_list[region][res.ScheduledActionARN] = res
                    null

            #clw
            if resources.DescribeAlarms
                _.map resources.DescribeAlarms.member, ( res, i ) ->
                    MC.data.resource_list[region][res.AlarmArn] = res
                    null

            #sns sub
            if resources.ListSubscriptions

                #init
                if !MC.data.resource_list[region].Subscriptions
                    MC.data.resource_list[region].Subscriptions = []

                _.map resources.ListSubscriptions.member, ( res, i ) ->
                    MC.data.resource_list[region].Subscriptions.push res
                    null

            #sns topic
            if resources.ListTopics
                _.map resources.ListTopics.member, ( res, i ) ->
                    MC.data.resource_list[region][res.TopicArn] = res
                    null




            null

        getAppResourcesService : ( region, app_id )->

            me = this

            app_model.resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region,  app_id

            app_model.once 'APP_RESOURCE_RETURN', ( result ) ->

                console.log 'APP_RESOURCE_RETURN'

                resource_source = result.resolved_data

                me._cacheResource resource_source, region

                null

    }

    model = new DesignModel()

    return model
