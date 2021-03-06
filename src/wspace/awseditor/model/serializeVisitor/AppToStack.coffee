define [ "../DesignAws" ], (Design)->

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
                    compo.resource.Attachment.AttachmentId = ""
                when 'AWS.EC2.Instance'
                    compo.resource.InstanceId = ""
                    _.each compo.resource.BlockDeviceMapping, (e)->
                        if e.Ebs?.VolumeType and e.Ebs.VolumeType isnt "io1" and e.Ebs.Iops
                            compo.Ebs.Iops = ""
                when 'AWS.VPC.Subnet'
                    compo.resource.SubnetId = ""
                when 'AWS.EC2.EIP'
                    compo.resource.AllocationId = ""
                    compo.resource.PublicIp = ""
                when 'AWS.VPC.RouteTable'
                    compo.resource.RouteTableId = ""
                    compo.resource.AssociationSet.forEach (e)->
                        e.RouteTableAssociationId = ""
                        return
                when 'AWS.EC2.SecurityGroup'
                    compo.resource.GroupId = ""
                    compo.resource.GroupName = compo.name
#                when 'AWS.EC2.KeyPair'
#                    compo.resource.KeyFingerprint = ""
#                    compo.resource.KeyName = compo.name
                when 'AWS.VPC.InternetGateway'
                    compo.resource.InternetGatewayId = ""
                when 'AWS.VPC.NetworkAcl'
                    compo.resource.NetworkAclId = ""
                    compo.resource.AssociationSet.forEach (e)->
                        e.NetworkAclAssociationId = ""
                        return
                when 'AWS.VPC.VPNGateway'
                    compo.resource.VpnGatewayId = ""
                when 'AWS.VPC.VPNConnection'
                    compo.resource.VpnConnectionId = ""
                when 'AWS.VPC.CustomerGateway'
                    compo.resource.CustomerGatewayId = ""
                when "AWS.EC2.EBS.Volume"
                    compo.resource.VolumeId = ""
                    if  compo.resource.VolumeType and compo.resource.VolumeType isnt "io1" and compo.resource.Iops
                        compo.resource.Iops = ""
                        null
#                when "AWS.VPC.DhcpOptions"
#                    compo.resource.DhcpOptionsId = ""
                when 'AWS.EC2.Tag'
                    if compo.name is "EC2InternalTags"
                        delete components[comp]
                    else
                        _.each (compo.resource), (item, index)->
                            # remove tag whose key start with `aws:`
                            if item.Key.indexOf("aws:") == 0
                                delete compo.resource[index]
                        compo.resource = _.compact compo.resource

                when 'AWS.AutoScaling.Tag'
                    if compo.name is "AutoScalingInternalTags"
                        delete components[comp]
                when 'AWS.ELB'
                    compo.resource.DNSName = ""
                    compo.resource.LoadBalancerName = compo.name
#                when 'AWS.IAM.ServerCertificate'
#                    compo.resource.ServerCertificateMetadata.Arn = ""
#                    compo.resource.ServerCertificateMetadata.ServerCertificateId = ""
#                    compo.resource.ServerCertificateMetadata.ServerCertificateName = compo.name
                when 'AWS.AutoScaling.LaunchConfiguration'
                    compo.resource.LaunchConfigurationARN = ""
                    compo.resource.LaunchConfigurationName = compo.name
                    _.each compo.resource.BlockDeviceMapping, (e)->
                        if e.Ebs?.VolumeType and e.Ebs.VolumeType isnt 'io1' and e.Ebs.Iops
                          e.Ebs.Iops = ""
                          null
                when 'AWS.AutoScaling.Group'
                    compo.resource.AutoScalingGroupARN = ""
                    compo.resource.AutoScalingGroupName = compo.name
                when 'AWS.AutoScaling.NotificationConfiguration'
                    console.log "Do Nothing Here"
                when 'AWS.SNS.Subscription'
                    console.log "Do Nothing Here"
#                when "AWS.SNS.Topic"
#                    compo.resource.TopicArn = ""
                when 'AWS.AutoScaling.ScalingPolicy'
                    compo.resource.PolicyARN = ""
                when 'AWS.CloudWatch.CloudWatch'
                    compo.resource.AlarmArn = ""
                    compo.resource.AlarmName = compo.name
                when 'AWS.RDS.DBInstance'
                    sourceDBId = ''
                    level2DBId = MC.extractID(compo.resource.ReadReplicaSourceDBInstanceIdentifier)
                    if level2DBId
                        level2DBComp = components[level2DBId]
                        if level2DBComp
                            sourceDBId = level2DBComp.resource.ReadReplicaSourceDBInstanceIdentifier
                    if not sourceDBId
                        compo.resource.CreatedBy = ""
                        compo.resource.DBInstanceIdentifier = ""
                        compo.resource.Endpoint.Address = ""
                        compo.resource.PreferredBackupWindow = ""
                        compo.resource.PreferredMaintenanceWindow = ""
                        if compo.resource.ReadReplicaSourceDBInstanceIdentifier
                            compo.resource.MasterUserPassword = "****"
                        else
                            compo.resource.MasterUserPassword = "12345678"
                    else
                        level2DBComp.resource.BackupRetentionPeriod = 0
                        delete components[compo.uid]
                when "AWS.RDS.DBSubnetGroup"
                    compo.resource.CreatedBy = ''
                    compo.resource.DBSubnetGroupName = ""
                when 'AWS.RDS.OptionGroup'
                    compo.resource.OptionGroupName = ""
                    compo.resource.CreatedBy = ""
                else

    null

