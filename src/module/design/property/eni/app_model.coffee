#############################
#  View Mode for design/property/eni
#############################

define [ '../base/model' ], ( PropertyModel ) ->

    EniAppModel = PropertyModel.extend {

        defaults :
          id: null

        init : ( eni_uid )->

          this.set 'id', eni_uid

          myEniComponent = MC.canvas_data.component[ eni_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          eni = $.extend true, {}, appData[ myEniComponent.resource.NetworkInterfaceId ]
          eni.name = myEniComponent.name

          if eni.status == "in-use"
            eni.isInUse = true

          eni.sourceDestCheck = if eni.sourceDestCheck is "true" then "enabled" else "disabled"

          for i in eni.privateIpAddressesSet.item
            i.primary = i.primary == true

          this.set eni

        getSGList : () ->

            # resourceId = this.get 'id'

            # # find stack by resource id
            # resourceCompObj = null
            # _.each MC.canvas_data.component, (compObj, uid) ->
            #     if compObj.resource.InstanceId is resourceId
            #         resourceCompObj = compObj
            #     null

            # sgAry = []
            # if resourceCompObj
            #     sgAry = resourceCompObj.resource.SecurityGroupId

            uid = this.get 'id'
            sgAry = MC.canvas_data.component[uid].resource.GroupSet

            sgUIDAry = []
            _.each sgAry, (value) ->
                sgUID = value.GroupId.slice(1).split('.')[0]
                sgUIDAry.push sgUID
                null

            return sgUIDAry

        getEni : () ->

          uid = this.get 'get_uid'
          instanceUID = uid

          defaultVPCId = MC.aws.aws.checkDefaultVPC()
          if !MC.canvas_data.component[uid].resource.SubnetId and !defaultVPCId
            return

          eni_detail = {}

          eni_detail.eni_ips = []

          eni_count = 0

          subnetCIDR = ''
          if defaultVPCId
            subnetObj = MC.aws.vpc.getSubnetForDefaultVPC(instanceUID)
            subnetCIDR = subnetObj.cidrBlock
          else
            subnetUID = MC.canvas_data.component[uid].resource.SubnetId.split('.')[0][1...]
            subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

          prefixSuffixAry = MC.aws.subnet.genCIDRPrefixSuffix(subnetCIDR)

          _.map MC.canvas_data.component, ( val, key ) ->

            if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

              eni_detail.description = val.resource.Description

              if val.resource.AssociatePublicIpAddress

                eni_detail.asso_public_ip = val.resource.AssociatePublicIpAddress
              else
                eni_detail.asso_public_ip = false

              eni_detail.sourceCheck = true if val.resource.SourceDestCheck == 'true' or val.resource.SourceDestCheck == true

              eni_detail.eni_ips = $.extend true, {}, val.resource.PrivateIpAddressSet

              $.each eni_detail.eni_ips, ( idx, ip_detail) ->

                ip_ref = '@' + val.uid + '.resource.PrivateIpAddressSet.' + idx + '.PrivateIpAddress'

                ip_detail.prefix = prefixSuffixAry[0]

                if ip_detail.AutoAssign is true or ip_detail.AutoAssign is 'true'
                  ip_detail.suffix = prefixSuffixAry[1]
                else
                  # subnetComp = MC.aws.eni.getSubnetComp(uid)
                  # subnetCIDR = subnetComp.resource.CidrBlock
                  ipAddress = ip_detail.PrivateIpAddress
                  fixPrefixSuffixAry = MC.aws.eni.getENIDivIPAry(subnetCIDR, ipAddress)
                  ip_detail.suffix = fixPrefixSuffixAry[1]

                $.each MC.canvas_data.component, ( comp_uid, comp ) ->

                  if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.PrivateIpAddress == ip_ref

                    ip_detail.has_eip = true

                    return false
                eni_count += 1
                null
            else if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid

              eni_count += 1

            null

          if eni_count > 1

            eni_detail.multi_enis = true

          else
            eni_detail.multi_enis = false

          this.set 'eni_display', eni_detail
    }

    new EniAppModel()
