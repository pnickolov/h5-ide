define [ "Design" ], (Design)->

    # AppToStack is an util function to make sure a JSON is a stack JSON,
    # when serializing.
    Design.registerSerializeVisitor (components, layouts, options)->
        if not options or not options.toStack
            return

        for comp of components
            compo = components[comp]
            switch  compo.type
                when 'AWS.VPC.VPC'
                    compo.resource.VpcId = ""
                when 'AWS.VPC.NetworkInterface'
                    compo.resource.NetworkInterfaceId = ""
                when 'AWS.EC2.Instance'
                    compo.resource.PrivateIpAddress = ""
                    compo.resource.InstanceId = ""
                when 'AWS.VPC.Subnet'
                    compo.resource.SubnetId = ""
                when 'AWS.EC2.EIP'
                    compo.name = "EIP"
                    compo.resource.AllocationId = ""
                    compo.resource.PublicIp = ""
                when 'AWS.VPC.RouteTable'
                    compo.resource.RouteTableId = ""
                    compo.resource.AssociationSet.forEach (e)->
                        e.RouteTableAssociationId = ""
                        return
                when 'AWS.EC2.SecurityGroup'
                    compo.resource.GroupId = ""
                    compo.resource.GroupName = "WebServerSG"
                when 'AWS.EC2.KeyPair'
                    compo.resource.KeyFingerprint = ""
                    compo.resource.KeyName = "DefaultDP"
                when 'AWS.VPC.InternetGateway'
                    compo.resource.InternetGatewayId = ""
                when 'AWS.VPC.NetworkAcl'
                    compo.resource.NetworkAclId = ""
                    compo.resource.AssociationSet.forEach (e)->
                        e.NetworkAclAssociationId = ""
                        e.NetworkAclId = ""
                        return
                when 'AWS.VPC.VPNGateway'
                    compo.resource.VpnGatewayId = ""
                when 'AWS.VPC.VPNConnection'
                    compo.resource.VpnConnectionId = ""
                when 'AWS.VPC.CustomerGateway'
                    compo.resource.CustomerGatewayId = ""
                when 'AWS.EC2.Tag'
                    delete components[comp]
                else

    null

