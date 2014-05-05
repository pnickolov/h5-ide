define [ "Design" ], (Design)->

    # AppToStack is an util function to make sure a JSON is a stack JSON,
    # when serializing.
    Design.registerSerializeVisitor (components, layouts, options)->
        console.info arguments,"<==========="
        if not options or not options.toStack
            return

        # TODO : Remove everything that's not necessary in stack JSON. ( No need to return, just modifiy components and layouts )
        for comp of components
            compo = components[comp]
            console.log compo
            if compo.type is 'AWS.VPC.VPC'
                compo.resource.VpcId = ""
            if compo.type is 'AWS.VPC.NetworkInterface'
                compo.resource.NetworkInterfaceId = ""
            if compo.type is 'AWS.VPC.Instance'
                compo.resource.PrivateIpAddress = ""
                compo.resource.InstanceId = ""
            if compo.type is 'AWS.VPC.Subnet'
                compo.resource.SubnetId = ""
            if compo.type is 'AWS.EC2.EIP'
                compo.name = "EIP"
                compo.resource.AllocationId = ""
                compo.resource.PublicIp = ""
            if compo.type is 'AWS.VPC.RouteTable'
                compo.resource.RouteTableId
                compo.resource.AssociationSet.forEach (e)->
                    e.RouteTableAssociationId = ""
            if compo.type is 'AWS.EC2.SecurityGroup'
                compo.resource.GroupId = ""
                compo.resource.GroupName = "WebServerSG"
            if compo.type is 'AWS.EC2.keyPair'
                compo.resource.KeyFingerprint = ""
                compo.resource.KeyName = "DefaultDP"
            if compo.type is 'AWS.VPC.InternetGateway'
                compo.resource.InternetGatewayId = ""
            if compo.type is 'AWS.VPC.NetworkACL'
                compo.resource.AssociationSet.forEach (e)->
                    e.NetworkAclAssociationId = ""
                    e.NetworkAclId = ""
            if compo.type is 'AWS.EC2.Tag'
                delete components[comp]
        console.info components,"<===============>"
    null

