
define [ "constant",
         "Design",
         "../GroupModel",
         "../connection/RtbAsso",
         "i18n!nls/lang.js"
], ( constant, Design, GroupModel, RtbAsso, lang )->

  Model = GroupModel.extend {

    type    : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
    newNameTmpl : "subnet"

    defaults :
      x      : 2
      y      : 2
      width  : 17
      height : 17
      cidr   : ""

    initialize : ( attributes, option )->
      if not @attributes.cidr
        @attributes.cidr = @generateCidr()

      # Draw the node
      @draw(true)

      # Connect to the MainRT automatically
      RtbModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable )
      new RtbAsso( this, RtbModel.getMainRouteTable(), { implicit : true } )

      # Connect to the DefaultACL automatically
      Acl = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl )
      defaultAcl = Acl.getDefaultAcl()
      if defaultAcl
        AclAsso = Design.modelClassForType( "AclAsso" )
        new AclAsso( this, defaultAcl )

      null

    setCidr : ( cidr )->
      # No need to update eni ip, because the ip is autoassign at
      # the time we serialize()
      @set("cidr", cidr)
      @draw()
      null

    setAcl : ( uid )->
      AclAsso = Design.modelClassForType( "AclAsso" )
      new AclAsso( this, Design.instance().component( uid ) )
      null

    isReparentable : ( newParent )->
      for child in @children()
        if child.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance or child.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

          for attach in child.connectionTargets( "EniAttachment" )
            if attach.parent() isnt this
              return lang.ide.CVS_MSG_ERR_MOVE_ATTACHED_ENI

        if child.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group or child.type is "ExpandedAsg"
          if child.type is "ExpandedAsg"
            child = child.get("originalAsg")
          if child.getExpandAzs().indexOf( newParent ) != -1
            return sprintf lang.ide.CVS_MSG_ERR_DROP_ASG, child.get("name"), newParent.get("name")
      true

    isRemovable : ()->
      # The subnet is only un-removable if it connects to elb and the ElbAsso is not removable
      for cn in @connections("ElbSubnetAsso")
        if cn.isRemovable() isnt true

          # In stack mode, we allow the subnet to be deleted, if the Elb only connects
          # to resource that are children of this subnet
          notRemovable = true
          if @design().modeIsStack()
            notRemovable = false
            for ami in cn.getOtherTarget( @ ).connectionTargets("ElbAmiAsso")
              if ami.parent() isnt @ and ami.parent().parent() isnt @
                notRemovable = true
                break

          if notRemovable
            return { error : lang.ide.CVS_MSG_ERR_DEL_LINKED_ELB }

      true

    onParentChanged : ()->
      # When subnet is moved to another AZ. If this subnet connects to an Elb, which connects to target AZ's subnet. Then disconnect from the Elb.
      elbAsso = @connections("ElbSubnetAsso")[0]
      if not elbAsso then return

      for sb in elbAsso.getTarget(constant.AWS_RESOURCE_TYPE.AWS_ELB).connectionTargets("ElbSubnetAsso")
        if sb.parent() is @parent()
          # Disconnect
          elbAsso.remove()
          return
      null

    isValidCidr : ( cidr )->

      # 1. It must not conflicts with VPC
      if !MC.aws.subnet.isInVPCCIDR( @parent().parent().get("cidr") , cidr )
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
      if not @isCidrEnoughForIps( cidr )
        return {
          error  : "#{cidr} has not enough IP for the ENIs in this subnet."
        }

      # 4. Check Elb.
      if @connections( "ElbSubnetAsso" ).length and Number(cidr.split('/')[1]) > 27
        return {
          error : "The subnet is attached with a load balancer. The CIDR mask must be smaller than /27."
          shouldRemove : false
        }

      true

    isCidrConfilctWithSubnets : ( cidr )->
      cidr = cidr or @get("cidr")

      for sb in Model.allObjects()
        if sb isnt @
          conflict = MC.aws.subnet.isSubnetConflict( sb.get("cidr"), cidr )
          if conflict then return true

      return false

    isCidrEnoughForIps : ( cidr )->
      cidr = cidr or @get("cidr")

      ipCount = 0
      for child in @children()
        if child.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
          eni = child.getEmbedEni()
        else if child.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
          eni = child
        else
          continue

        ipCount += eni.get("ips").length

      maxIpCount = MC.aws.eni.getAvailableIPCountInCIDR( cidr )
      maxIpCount >= ipCount

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

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet

    diffJson : ()-> # Disable diff for thie Model

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
