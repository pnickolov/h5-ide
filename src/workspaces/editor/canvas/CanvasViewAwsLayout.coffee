
define [ "./CanvasViewAws", "./CanvasViewLayout", "constant" ], ( AwsCanvasView, CanvasViewLayoutHelpers, constant )->

  # Group Helpers
  __sortInstance = ( instances )->
    instances.sort ( a, b )-> b.component.connections("ElbAmiAsso").length - a.component.connections("ElbAmiAsso")

  GroupMForSubnet = ( children )->
    group = CanvasViewLayoutHelpers.DefaultGroupMethod.call this, children
    instanceGroup = null
    eniGroup = null

    subnetChildren = []

    for ch in group
      if ch.type is "AWS.VPC.NetworkInterface_group"
        eniGroup = ch
      else if ch.type is "AWS.EC2.Instance_group"
        instanceGroup = ch
      else
        subnetChildren.push ch

    if instanceGroup and eniGroup
      linkedInstances = {}
      linkedEnis      = {}
      pairGroup       = []

      existingEnis = {}
      existingEnis[ eni.component.id ] = eni for eni in eniGroup.children

      lonelyInstances = []
      lonelyEnis      = []

      for instance in instanceGroup.children
        enis = instance.component.connectionTargets( "EniAttachment" )
        if not enis.length
          lonelyInstances.push instance
        else
          eniInstanceG = [ instance ]
          linkedInstances[ instance.component.id ] = true

          for eni in enis
            linkedEnis[ eni.id ] = true
            eniInstanceG.push( existingEnis[ eni.id ] )

          pairGroup.push {
            type     : "AmiEniPair"
            children : eniInstanceG
          }

      for eni in eniGroup.children
        if not linkedEnis[ eni.component.id ]
          lonelyEnis.push eni

      __sortInstance( lonelyInstances )
      subnetChildren.push {
        type     : "AWS.EC2.Instance_group"
        children : lonelyInstances
      }

      subnetChildren.push {
        type     : "AmiEniPari_group"
        children : pairGroup
      }

      subnetChildren.push {
        type     : "AWS.VPC.NetworkInterface_group"
        children : lonelyEnis
      }

      subnetChildren
    else
      if instanceGroup
        __sortInstance( instanceGroup.children )
        subnetChildren.push instanceGroup

      if eniGroup      then subnetChildren.push eniGroup
      subnetChildren


  GroupMForDbSubnet = ( children )->
    msGroup     = []
    normalGroup = []

    masters      = {}
    lonelySlaves = []

    for ch in children
      if ch.component.slaves().length
        masters[ ch.component.id ] = [ ch ]

    for ch in children
      master = ch.component.master()
      if master
        if masters[ master.id ]
          masters[ master.id ].push ch
        else
          lonelySlaves.push ch
      else if not masters[ ch.component.id ]
        normalGroup.push ch

    lonelyMasters = []
    for id, masterSlave of masters
      if masterSlave.length is 1
        lonelyMasters.push masterSlave[0]
      else
        msGroup.push {
          type     : "MasterSlave"
          children : masterSlave
        }

    if lonelyMasters.length
      msGroup.push {
        type     : "MasterSlave"
        children : lonelyMasters
      }

    ch = []
    if msGroup.length
      ch.push {
        type : "MasterSlave_group"
        children : msGroup
      }

    if lonelySlaves.length
      ch.push {
        type     : "AWS.RDS.DBInstance_group"
        children : lonelySlaves
      }

    if normalGroup.length
      ch.push {
        type     : "AWS.RDS.DBInstance_group"
        children : normalGroup
      }

    ch


  # Arrange Helpers
  ArrangeForAzs = ( children )->
    if not children.length
      return {
        width  : 0
        height : 0
      }

    if children.length is 1
      return {
        width  : children[0].width
        height : children[0].height
      }

    children.sort ( a, b )-> b.height - a.height
    i = 0
    while i < children.length
      ch1 = children[ i ]
      ch2 = children[ i + 1 ]
      if ch2 and ch2.width * ch2.height > ch1.width * ch1.height
        children[ i ] = ch2
        children[ i + 1 ] = ch1
      i += 2

    y2 = children[0].height + 15
    x1 = 0
    x2 = 0
    i  = 0

    while i < children.length
      ch1 = children[ i ]
      ch2 = children[ i + 1 ]

      ch1.y = 0
      if ch2
        ch1.x = x1
        x1 += ch1.width + 4
        ch2.x = x2
        ch2.y = y2
        x2 += ch2.width + 4
      else
        if x1 > x2
          ch1.x = x2
          ch1.y = y2
          x2 += ch1.width + 4
        else
          ch1.x = x1
          ch1.y = 0
          x1 += ch1.width + 4

      i += 2

    {
      width  : Math.max( x1, x2 ) - 4
      height : children[1].height + y2
    }


  ArrangeForVpc = ( children )->
    def = AutoLayoutConfig[ constant.RESTYPE.VPC ]
    childMap = {}
    for ch in children
      childMap[ ch.type ] = ch

    baseX  = if childMap[ "AWS.ELB_group" ] then 18 else 5
    baseY  = 4
    subnetGroupBaseX = baseX

    ch = childMap[ "AWS.VPC.RouteTable_group" ]
    if ch
      ch.x  = baseX
      ch.y  = baseY
      baseY += ch.height + 3

    elbBaseY = baseY
    ch = childMap[ "AWS.EC2.AvailabilityZone_group" ]
    if ch
      ch.x  = baseX
      ch.y  = baseY
      subnetGroupBaseX = baseX + ch.width + 4
      elbBaseY += ch.children[0].y + ch.children[0].height + 3

    ch = childMap[ "AWS.ELB_group" ]
    if ch
      ch.x = 5
      ch.y = elbBaseY
      if ch.x + ch.width > subnetGroupBaseX
        subnetGroupBaseX = ch.x + ch.width + 4

    ch = childMap[ "AWS.RDS.DBSubnetGroup_group" ]
    if ch
      ch.x = subnetGroupBaseX
      ch.y = baseY

    width  = 0
    height = 0
    for ch in children
      w = ch.x + ch.width
      if w > width then width = w
      h = ch.y + ch.height
      if h > height then height = h

    {
      width  : width  + 5
      height : height + 4
    }

  ArrangeForSvg = ( children )->
    newChs = []
    for ch in children
      if ch.type is "AWS.VPC.VPC_group"
        newChs.unshift( ch )
      else
        newChs.push( ch )

    CanvasViewLayoutHelpers.DefaultArrangeMethod.call this, newChs

  # Sort Helpers
  SortForVpc = ( children )->
    ###
    # 1. Main Rtb should be before other RTB.
    # 2. Internet Elb should be before internal Elb
    # 3. Connected Elb should be before none connected Elb
    ###
    ExternalElbs  = []
    InternalElbs  = []
    otherChildren = []

    for ch in children
      if ch.type is constant.RESTYPE.RT
        if ch.get("main")
          otherChildren.unshift( ch )
          continue

      if ch.type is constant.RESTYPE.ELB
        col = if ch.get("internal") then InternalElbs else ExternalElbs
        if ch.connections("ElbAmiAsso").length
          col.unshift( ch )
        else
          col.push( ch )
        continue

      otherChildren.push ch

    otherChildren.concat( ExternalElbs, InternalElbs )



  # Definations
  AutoLayoutConfig = AwsCanvasView.prototype.autoLayoutConfig =
    "SVG" : {
      arrangeMethod : ArrangeForSvg
      space : 6
    }
    "AWS.VPC.CustomerGateway_group"  : {
      arrangeMethod : "ArrangeVertical"
      space : 2
    }
    "AWS.VPC.VPC" : {
      arrangeMethod : ArrangeForVpc
      space         : 4
      sortMethod    : SortForVpc
      margin        : 2
      width         : 60
      height        : 60
    }
    "AWS.VPC.VPNGateway" : {
      sticky : true
    }
    "AWS.VPC.InternetGateway" : {
      sticky : true
    }

    "AWS.ELB_group" : {
      space   : 11
    }
    "AWS.ELB" : {
      width   : 9
      height  : 9
    }
    "AWS.VPC.RouteTable_group" : {
      space   : 4
    }
    "AWS.VPC.RouteTable":{
      width   : 9
      height  : 9
    }
    "AWS.EC2.AvailabilityZone_group" : {
      arrangeMethod : ArrangeForAzs
    }
    "AWS.EC2.AvailabilityZone" : {
      margin : 2
      width  : 15
      height : 15
    }
    "AWS.RDS.DBSubnetGroup_group" : {
      arrangeMethod : "ArrangeBinPack"
      space : 4
    }
    "AWS.RDS.DBSubnetGroup" : {
      groupMethod : GroupMForDbSubnet
      margin : 2
      space  : 3
      width  : 11
      height : 11
    }
    "AWS.RDS.DBInstance" : {
      width  : 9
      height : 9
    }
    "AWS.RDS.DBInstance_group" : {
      arrangeMethod : "ArrangeBinPack"
      space : 2
    }
    "MasterSlave" : {
      arrangeMethod : "ArrangeVertical"
      space : 2
    }
    "MasterSlave_group" : {
      space : 1
    }
    "AWS.AutoScaling.LaunchConfiguration" : {
      ignore : true
    }

    "AWS.VPC.NetworkInterface_group" : {
      arrangeMethod : "ArrangeBinPack"
      space  : 4
    }
    "AWS.VPC.NetworkInterface" : {
      width  : 9
      height : 9
    }
    "AWS.EC2.Instance_group" : {
      arrangeMethod : "ArrangeBinPack"
      space  : 2
    }
    "AWS.EC2.Instance" : {
      width  : 9
      height : 9
    }
    "AWS.AutoScaling.Group_group" : {
      arrangeMethod : "ArrangeBinPack"
      space : 4
    }
    "AWS.AutoScaling.Group" : {
      width  : 13
      height : 13
    }
    "AWS.VPC.Subnet_group" : {
      arrangeMethod : "ArrangeBinPack"
      space : 2
    }
    "AWS.VPC.Subnet" : {
      groupMethod : GroupMForSubnet
      margin : 2
      space  : 2
      width  : 13
      height : 13
    }
    "AWS.VPC.CustomerGateway" : {
      width  : 17
      height : 10
    }
    "AmiEniPair" : {
      space : 1
    }
    "AmiEniPari_group" : {
      arrangeMethod : "ArrangeVertical"
      space : 1
    }

  null
