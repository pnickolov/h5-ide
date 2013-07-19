#############################
#  View Mode for design/property/vpc
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], ( constant ) ->

    VPCModel = Backbone.Model.extend {

        # defaults :
        #     'set_xxx'    : null
        #     'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getRenderData : ( uid ) ->
            component = MC.canvas_data.component[ uid ]

            dhcpid = component.resource.DhcpOptionsId

            data =
                uid            : uid
                component      : component
                dnsSupport     : component.resource.EnableDnsSupport   == "true"
                dnsHosts       : component.resource.EnableDnsHostnames == "true"
                defaultTenancy : component.resource.InstanceTenancy    == "default"
                noneDhcp       : component.resource.DhcpOptionsId      == "default"

            if !data.noneDhcp
                if dhcpid
                    data.dhcp = this.getDHCPOptions uid

                if !data.dhcp
                    data.dhcp =
                        domainName   : this.defaultDomainName uid
                        useAmazonDNS : true
            else
                data.dhcp = {}

            data

        setName : ( uid, newName ) ->
            MC.canvas_data.component[ uid ].name = newName
            null

        setCIDR : ( uid, newCIDR ) ->
            MC.canvas_data.component[ uid ].resource.CidrBlock = newCIDR
            null

        getName : ( uid ) ->
            MC.canvas_data.component[ uid ].name

        getCIDR : ( uid ) ->
            MC.canvas_data.component[ uid ].resource.CidrBlock

        setTenancy : ( uid, tenancy ) ->
            component = MC.canvas_data.component[ uid ]
            component.resource.InstanceTenancy = tenancy

            console.log "UID:", uid, "InstanceTenancy:", component.resource.InstanceTenancy

        setDnsSupport : ( uid, enable ) ->
            component = MC.canvas_data.component[ uid ]
            component.resource.EnableDnsSupport = if enable then "true" else "false"
            console.log "UID:", uid, "VPC Resource:", component.resource

        setDnsHosts : ( uid, enable ) ->
            component = MC.canvas_data.component[ uid ]
            component.resource.EnableDnsHostnames = if enable then "true" else "false"
            console.log "UID:", uid, "VPC Resource:", component.resource

        parseDhcpId : ( dhcpid ) ->
            extract = /@([^.]+)\./.exec( dhcpid )
            if extract
                extract[1]
            else
                dhcpid

        getDHCPComponent : ( vpcUid ) ->
            vpc    = MC.canvas_data.component[ vpcUid ]
            dhcpid = this.parseDhcpId( vpc.resource.DhcpOptionsId )

            if dhcpid == "default"
                return null

            if dhcpid == ""
                # Create a new DHCP Component
                dhcpid = MC.guid()

                component_data = $.extend true, {}, MC.canvas.DHCP_JSON.data
                component_data.uid = dhcpid
                component_data.resource.VpcId = "@" + vpcUid + ".resource.VpcId"

                components = MC.canvas.data.get 'component'
                components[ dhcpid ] = component_data
                MC.canvas.data.set 'component', components

                vpc.resource.DhcpOptionsId = "@" + dhcpid + ".resource.DhcpOptionsId"
                return component_data
            else
                return MC.canvas_data.component[ dhcpid ]

            null


        # This method only sets whether or not the VPC use none DHCP
        # It does not modify already exists DHCP when enabling DHCP
        setDhcp : ( uid, enable ) ->
            component = MC.canvas_data.component[ uid ]
            if enable
                if component.resource.DhcpOptionsId == "default"
                    component.resource.DhcpOptionsId = ""
            else
                dhcpid = this.parseDhcpId component.resource.DhcpOptionsId
                noDHCP = dhcpid == ""

                component.resource.DhcpOptionsId = "default"

                # The VPC component has no associated DHCP component
                noDHCP = dhcpid == ""
                if noDHCP
                    return

                # delete already exists DHCP component
                component_data = MC.canvas.data.get('component')
                if component_data[ dhcpid ].type == constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions
                    delete component_data[ dhcpid ]
                    console.log "Deleted DHCP component", component_data

                MC.canvas.data.set('component', component_data)
            null

        # DHCP Options Setting
        setDHCPOptions : ( vpcUid, options ) ->

            configSet = []
            if options.domainName
                configSet.push
                    Key : "domain-name"
                    ValueSet : [ Value : options.domainName ]

            if options.domainServers || options.useAmazonDns
                values = []
                if options.useAmazonDns
                    values.push Value : "AmazonProvidedDNS"

                if options.domainServers
                    values.push Value : s for s in options.domainServers

                configSet.push
                    Key : "domain-name-servers"
                    ValueSet : values

            if options.ntpServers
                values = []
                values.push Value : s for s in options.ntpServers
                configSet.push
                    Key : "ntp-servers"
                    ValueSet : values

            if options.netbiosServers
                values = []
                values.push Value : s for s in options.netbiosServers
                configSet.push
                    Key : "netbios-name-servers"
                    ValueSet : values

            if options.netbiosType
                configSet.push
                    Key : "netbios-node-type"
                    ValueSet : [ Value : options.netbiosType ]

            this.getDHCPComponent( vpcUid ).resource.DhcpConfigurationSet = configSet
            null

        # TODO : Generate default domain name for dhcp
        defaultDomainName : ( vpcUid ) ->
            "XXXXXXXXXX"

        getDHCPOptions : ( vpcUid ) ->
            dhcpid = this.parseDhcpId MC.canvas_data.component[ vpcUid ].resource.DhcpOptionsId
            dhcp   = MC.canvas_data.component[ dhcpid ]

            config = dhcp.resource.DhcpConfigurationSet
            if config.length == 0
                return null

            keyMap =
                "domain-name-servers"  : "domainServers"
                "netbios-name-servers" : "netbiosServers"
                "ntp-servers"          : "ntpServers"

            data = { useAmazonDns : false }
            for i in config
                if i.Key == "domain-name"
                    data.domainName  = i.ValueSet[0].Value

                else if i.Key == "netbios-node-type"
                    data.netbiosType = i.ValueSet[0].Value

                else
                    key = keyMap[ i.Key ]
                    if !key
                        continue

                    data[key] = values = []
                    for value in i.ValueSet
                        if value.Value == "AmazonProvidedDNS"
                            data.useAmazonDns = true
                        else
                            values.push value.Value

            data
    }

    model = new VPCModel()

    return model
