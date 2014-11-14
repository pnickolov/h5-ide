
define [ "./CanvasViewOs", "CanvasViewLayout", "constant" ], ( OsCanvasView, CanvasViewLayoutHelpers, constant )->

  GroupMForSubnet = ( children )->
    group = CanvasViewLayoutHelpers.DefaultGroupMethod.call this, children

    subnetChildren = []

    serverGroup = portGroup = vipGroup = poolGroup = []

    console.log group

    for ch in group
      if ch.type is "OS::Nova::Server_group"
        subnetChildren.push ch
      else if ch.type is "OS::Neutron::Port_group"
        portGroup = ch.children
      else if ch.type is "OS::Neutron::VIP_group"
        vipGroup = ch.children
      else if ch.type is "OS::Neutron::Pool_group"
        poolGroup = ch.children

    elbChildren = []

    for pool in poolGroup
      vip = pool.component.connectionTargets( "OsListenerAsso" )[0]
      idx = -1
      for v, i in vipGroup
        if v.component is vip
          idx = i
          break
      if idx >= 0
        vipGroup.splice( idx, 1 )
        elbChildren.push {
          type     : "ELB_pair"
          children : [ pool, v ]
        }
      else
        elbChildren.push pool

    for vip in vipGroup
      elbChildren.push vip

    if elbChildren.length
      subnetChildren.push {
        type     : "ELB_group"
        children : elbChildren
      }

    if portGroup.length
      subnetChildren.push {
        type     : "OS::Neutron::Port_group"
        children : portGroup
      }

    return subnetChildren

  ArrangeForSubnetGroup = ( children )->
    children.sort (a,b)-> b.children.length - a.children.length

    x1 = -2
    x2 = -2
    y1 = 0
    y2 = 0

    ch2 = []

    for ch, idx in children
      if idx % 2 is 0
        ch.y = 0
        ch.x = x1 + 2
        x1 = ch.x + ch.width
        if ch.height > y1
          y1 = ch.height
      else
        ch2.push ch
        ch.x = x2 + 2
        x2 = ch.x + ch.width
        if ch.height > y2
          y2 = ch.height

    for ch in ch2
      ch.y = y1 + 2

    {
      width  : Math.max( x1, x2 )
      height : y1 + 2 + y2
    }

  # Definations
  AutoLayoutConfig = OsCanvasView.prototype.autoLayoutConfig =
    "SVG" : {
      space : 6
    }
    "OS::Neutron::Network" : {
      space      : 4
      margin     : 3
      width      : 60
      height     : 60
    }
    "OS::Neutron::Router_group" : {
      arrangeMethod : "ArrangeBinPack"
      space   : 4
    }
    "OS::Neutron::Router":{
      width   : 8
      height  : 8
    }
    "OS::Neutron::Subnet_group" : {
      arrangeMethod : ArrangeForSubnetGroup
      space         : 2
    }
    "OS::Neutron::Subnet" : {
      groupMethod : GroupMForSubnet
      arrangeMethod : "ArrangeVertical"
      space  : 2
      margin : 2
      width  : 8
      height : 8
    }
    "OS::Nova::Server_group" : {
      space  : 2
    }
    "OS::Nova::Server" : {
      width  : 8
      height : 8
    }
    "OS::Neutron::Port" : {
      width  : 8
      height : 8
    }
    "OS::Neutron::VIP" : {
      width  : 8
      height : 8
    }
    "OS::Neutron::Pool" : {
      width  : 8
      height : 8
    }
    "ELB_group" : {
      arrangeMethod : "ArrangeBinPack"
      space : 2
    }
    'ELB_pair' : {
      space : 2
    }

  null
