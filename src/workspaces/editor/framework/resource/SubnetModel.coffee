
define [ "constant",
         "Design",
         "../GroupModel",
         "../connection/RtbAsso",
         "i18n!/nls/lang.js"
], ( constant, Design, GroupModel, RtbAsso, lang )->

  Model = GroupModel.extend {

    type    : constant.RESTYPE.SUBNET
    newNameTmpl : "subnet"

    defaults :
      cidr   : ""

    initialize : ( attributes, option )->
      if not @attributes.cidr
        @attributes.cidr = @generateCidr()

      # Connect to the MainRT automatically
      RtbModel = Design.modelClassForType( constant.RESTYPE.RT )
      new RtbAsso( this, RtbModel.getMainRouteTable(), { implicit : true } )

      # Connect to the DefaultACL automatically
      Acl = Design.modelClassForType( constant.RESTYPE.ACL )
      defaultAcl = Acl.getDefaultAcl()
      if defaultAcl
        AclAsso = Design.modelClassForType( "AclAsso" )
        new AclAsso( this, defaultAcl )

      null

    setCidr : ( cidr )->
      # No need to update eni ip, because the ip is autoassign at
      # the time we serialize()
      validCIDR = MC.getValidCIDR(cidr)
      @set("cidr", validCIDR)
      null

    setAcl : ( uid )->
      AclAsso = Design.modelClassForType( "AclAsso" )
      new AclAsso( this, Design.instance().component( uid ) )
      null

    isReparentable : ( newParent )->
      for child in @children()
        if child.type is constant.RESTYPE.INSTANCE or child.type is constant.RESTYPE.ENI

          for attach in child.connectionTargets( "EniAttachment" )
            if attach.parent() isnt this
              return lang.ide.CVS_MSG_ERR_MOVE_ATTACHED_ENI

        if child.type is constant.RESTYPE.ASG or child.type is "ExpandedAsg"
          if child.type is "ExpandedAsg"
            child = child.get("originalAsg")
          if child.getExpandAzs().indexOf( newParent ) != -1
            return sprintf lang.ide.CVS_MSG_ERR_DROP_ASG, child.get("name"), newParent.get("name")
      true

    isRemovable : ()->

      az = @parent()

      if @connections("SubnetgAsso").length > 0
        return { error : lang.ide.RDS_MSG_ERR_REMOVE_SUBNET_FAILED_CAUSEDBY_USEDBY_SBG }

      # The subnet is only un-removable if it connects to elb and the ElbAsso is not removable
      for cn in @connections("ElbSubnetAsso")
        if cn.isRemovable() isnt true

          # In stack mode, we allow the subnet to be deleted, if the Elb only connects
          # to resource that are children of this subnet
          if not @design().modeIsStack()
            return { error : lang.ide.CVS_MSG_ERR_DEL_LINKED_ELB }

          for ami in cn.getOtherTarget( @ ).connectionTargets("ElbAmiAsso")
            if ami.parent() is @ or ami.parent().parent() is @
              # This ami/lc is child of the subnet. Ignore it.
              continue

            # The ami is not child of the subnet, finds out if its az is the
            # same as this subnet's
            childAZ = ami.parent()
            while childAZ
              if childAZ is az
                return { error : lang.ide.CVS_MSG_ERR_DEL_LINKED_ELB }
              childAZ = childAZ.parent()

      true

    onParentChanged : ()->
      # When subnet is moved to another AZ. If this subnet connects to an Elb, which connects to target AZ's subnet. Then disconnect from the Elb.
      elbAsso = @connections("ElbSubnetAsso")[0]
      if not elbAsso then return

      for sb in elbAsso.getTarget(constant.RESTYPE.ELB).connectionTargets("ElbSubnetAsso")
        if sb.parent() is @parent()
          # Disconnect
          elbAsso.remove()
          return
      null

    isValidCidr : ( cidr )->

      # 1. It must not conflicts with VPC
      if !Model.isInVPCCIDR( @parent().parent().get("cidr") , cidr )
        return {
          error  : "#{cidr} conflicts with VPC CIDR."
          detail : "Subnet CIDR block should be a subset of VPC's."
        }

      # 2. It must not conflicts with other subnet in the same az.
      if @isCidrConfilctWithSubnets( cidr )
        return {
          error  : "#{cidr} conflicts with other subnet."
          detail : "Please choose a CIDR block not conflicting with existing subnet."
        }

      # 3. It must have enough space for its Eni's Ip.
      if @getAvailableIPCountInSubnet( cidr ) <= 0
        return {
          error  : "#{cidr} has not enough IP for the ENIs in this subnet."
        }

      true

    isCidrConfilctWithSubnets : ( cidr )->
      cidr = cidr or @get("cidr")

      for sb in Model.allObjects()
        if sb isnt @
          conflict = Model.isCidrConflict( sb.get("cidr"), cidr )
          if conflict then return true

      return false

    getAvailableIPCountInSubnet : ( cidr )->
      cidr = cidr or @get("cidr")

      ipCount = 0
      for child in @children()
        if child.type is constant.RESTYPE.INSTANCE
          eni = child.getEmbedEni()
        else if child.type is constant.RESTYPE.ENI
          eni = child
        else
          continue

        ipCount += eni.get("ips").length * eni.serverGroupCount()

      maxIpCount = Design.modelClassForType(constant.RESTYPE.ENI).getAvailableIPCountInCIDR( cidr )
      maxIpCount - ipCount

    generateCidr : () ->
      currentVPCCIDR = @parent().parent().get("cidr")

      vpcCIDRAry      = currentVPCCIDR.split('/')
      vpcCIDRIPStr    = vpcCIDRAry[0]
      vpcCIDRIPStrAry = vpcCIDRIPStr.split('.')
      vpcCIDRSuffix   = Number(vpcCIDRAry[1])

      if vpcCIDRSuffix isnt 16 then return ""

      # get max subnet number
      maxSubnetNum = -1
      for comp in Model.allObjects()
        subnetCIDR       = comp.get("cidr")
        subnetCIDRAry    = subnetCIDR.split('/')
        subnetCIDRIPStr  = subnetCIDRAry[0]
        subnetCIDRSuffix = Number(subnetCIDRAry[1])
        subnetCIDRIPAry  = subnetCIDRIPStr.split('.')

        currentSubnetNum = Number(subnetCIDRIPAry[2])

        if maxSubnetNum < currentSubnetNum
          maxSubnetNum = currentSubnetNum

      resultSubnetNum = maxSubnetNum + 1
      if resultSubnetNum > 255 then return ""

      vpcCIDRIPStrAry[2] = String(resultSubnetNum)
      vpcCIDRIPStrAry.join('.') + '/24'

    serialize : ()->

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          AvailabilityZone : @parent().createRef()
          VpcId            : @parent().parent().createRef( "VpcId" )
          SubnetId         : @get("appId")
          CidrBlock        : @get("cidr")

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.SUBNET

    genCIDRPrefixSuffix : (subnetCIDR) ->
      cutAry = subnetCIDR.split('/')
      ipAddr = cutAry[0]
      suffix = Number(cutAry[1])

      ipAddrAry = ipAddr.split('.')

      resultPrefix = ''
      resultSuffix = ''

      if suffix > 23
        resultPrefix = ipAddrAry[0] + '.' + ipAddrAry[1] + '.' + ipAddrAry[2] + '.'
        resultSuffix = 'x'
      else
        resultPrefix = ipAddrAry[0] + '.' + ipAddrAry[1] + '.'
        resultSuffix = 'x.x'

      return [resultPrefix, resultSuffix]

    isIPInSubnet : (ipAddr, subnetCIDR) ->

      isValid = true

      subnetIPAry = subnetCIDR.split('/')
      subnetSuffix = Number(subnetIPAry[1])
      subnetAddrAry = subnetIPAry[0].split('.')
      subnetIPBinStr = MC.getCidrBinStr subnetIPAry[0]

      subnetIPBinStrDiv = subnetIPBinStr.slice(0, subnetSuffix)

      ipAddrBinStr = MC.getCidrBinStr ipAddr

      ipAddrBinStrDiv = ipAddrBinStr.slice(0, subnetSuffix)
      ipAddrBinStrDivAnti = ipAddrBinStr.slice(subnetSuffix)

      suffixLength = 32 - subnetSuffix
      suffixZeroAry = _.map [1...suffixLength + 1], () -> '0'
      suffixZeroStr = suffixZeroAry.join('')
      suffixOneStr = suffixZeroStr.replace(/0/g, '1')

      suffixZeroStrNum = parseInt suffixZeroStr, 2
      suffixOneStrNum = parseInt suffixOneStr, 2

      readyAssignAry = [suffixZeroStrNum...suffixOneStrNum + 1]
      readyAssignAryLength = readyAssignAry.length

      result = false
      filterAry = []
      _.each readyAssignAry, (value, idx) ->
        newIPBinStr = MC.leftPadString(value.toString(2), suffixLength, "0")
        if idx in [0, 1, 2, 3, readyAssignAryLength - 1]
          filterAry.push(newIPBinStr)
        null

      if ipAddrBinStrDivAnti in filterAry
        return {
          isValid: false,
          isReserved: true
        }

      isValid = subnetIPBinStrDiv is ipAddrBinStrDiv
      return {
          isValid: isValid,
          isReserved: false
      }

    isCidrConflict : (ipCidr1, ipCidr2) ->
      ipCidr1BinStr = MC.getCidrBinStr(ipCidr1)
      ipCidr2BinStr = MC.getCidrBinStr(ipCidr2)

      ipCidr1Suffix = Number(ipCidr1.split('/')[1])
      ipCidr2Suffix = Number(ipCidr2.split('/')[1])

      if ipCidr1Suffix is 0 and (ipCidr1Suffix is ipCidr2Suffix)
        return true

      minIpCidrSuffix = ipCidr1Suffix
      if ipCidr1Suffix > ipCidr2Suffix
        minIpCidrSuffix = ipCidr2Suffix

      if ipCidr1BinStr.slice(0, minIpCidrSuffix) is ipCidr2BinStr.slice(0, minIpCidrSuffix) and minIpCidrSuffix isnt 0
        return true
      else
        return false

    isInVPCCIDR : (vpcCIDR, subnetCIDR) ->
      if not @isCidrConflict(vpcCIDR, subnetCIDR)
        return false

      return Number(subnetCIDR.split('/')[1]) >= Number(vpcCIDR.split('/')[1])

    isValidSubnetCIDR : (subnetCIDR) ->

      subnetCidrBinStr = MC.getCidrBinStr(subnetCIDR)
      subnetCidrSuffix = Number(subnetCIDR.split('/')[1])
      suffixIPBinStr = subnetCidrBinStr.slice(subnetCidrSuffix)
      suffixNum = parseInt(suffixIPBinStr)

      if (suffixNum is 0) or (suffixIPBinStr is '')
        return true

      return false


    autoAssignAllCIDR : (vpcCIDR, subnetCount) ->

      needBinNum = Math.ceil((Math.log(subnetCount))/(Math.log(2)))

      vpcIPSuffix = Number(vpcCIDR.split('/')[1])
      vpcIPBinStr = MC.getCidrBinStr(vpcCIDR)
      vpcIPBinLeftStr = vpcIPBinStr.slice(0, vpcIPSuffix)

      newSubnetSuffix = vpcIPSuffix + needBinNum

      newSubnetAry = []
      i = 0
      while i < subnetCount

        binSeq = MC.leftPadString(i.toString(2), needBinNum,"0")
        newSubnetBinStr = MC.rightPadString(vpcIPBinLeftStr + binSeq, 32, "0")

        newIPAry = _.map [0, 8, 16, 24], (value) ->
          return (parseInt newSubnetBinStr.slice(value, value + 8), 2)
        newIPStr = newIPAry.join('.')
        newSubnetStr = newIPStr + '/' + newSubnetSuffix

        newSubnetAry.push(newSubnetStr)

        ++i

      return newSubnetAry

    autoAssignSimpleCIDR : (newVPCCIDR, oldSubnetAry, oldVPCCIDR) ->

      newSubnetAry = []

      vpcCIDRAry = newVPCCIDR.split('/')
      vpcCIDRIPStr = vpcCIDRAry[0]
      vpcCIDRSuffix = Number(vpcCIDRAry[1])
      vpcIPAry = vpcCIDRIPStr.split('.')

      oldVPCCIDRSuffix = Number(oldVPCCIDR.split('/')[1])

      if vpcCIDRSuffix is 16 or (vpcCIDRSuffix is 24 and oldVPCCIDRSuffix is vpcCIDRSuffix)
        vpcIP1 = vpcIPAry[0]
        vpcIP2 = vpcIPAry[1]
        vpcIP3 = vpcIPAry[2]
        _.each oldSubnetAry, (subnetCIDR) ->
          subnetCIDRAry = subnetCIDR.split('/')
          subnetCIDRIPStr = subnetCIDRAry[0]
          subnetCIDRSuffix = Number(subnetCIDRAry[1])
          subnetIPAry = subnetCIDRIPStr.split('.')

          subnetIPAry[0] = vpcIP1
          subnetIPAry[1] = vpcIP2
          if vpcCIDRSuffix is 24
            subnetIPAry[2] = vpcIP3

          newSubnetCIDR = subnetIPAry.join('.') + '/' + subnetCIDRSuffix
          newSubnetAry.push(newSubnetCIDR)
          null

      return newSubnetAry


    deserialize : ( data, layout_data, resolve )->

      new Model {

        id    : data.uid
        name  : data.name
        appId : data.resource.SubnetId
        cidr  : data.resource.CidrBlock

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]

        parent : resolve( layout_data.groupUId )
      }

      null
  }

  Model
