
define [ "./CanvasViewAws", "constant" ], ( AwsCanvasView, constant )->

  # Default Group helpers
  DefaultGroupMethod = GroupMByType = ( children )->
    groups = []
    for type, childrens of _.groupBy( children, "type" )
      groups.push {
        type     : type + "_group"
        children : childrens
      }
    groups

  # Default Arrange Helpers
  DefaultArrangeMethod = ArrangeHorizontal = ( children )->

    def   = Defination[ @type ] || {}
    space = def.space  || 0

    x = 0
    height = 0

    for ch in children
      chDef    = Defination[ ch.type ] || {}
      chWidth  = ch.width  || chDef.width || 0
      chHeight = ch.height || chDef.height || 0

      ch.x = x
      ch.y = 0
      x += chWidth + space

      if chHeight and chHeight > height
        height = chHeight

    if children.length then x -= space

    {
      width  : x || def.width
      height : height || def.height
    }

  ArrangeVertical = ( children )->
    console.log( @type )
    def   = Defination[ @type ] || {}
    space = def.space  || 0

    y     = 0
    width = 0

    for ch in children
      chDef    = Defination[ ch.type ] || {}
      chWidth  = ch.width  || chDef.width  || 0
      chHeight = ch.height || chDef.height || 0

      ch.x = 0
      ch.y = y
      y += chHeight + space

      if chWidth and chWidth > width
        width = chWidth

    if children.length then y -= space

    {
      width  : width || def.width
      height : y || def.height
    }

  ArrangeMatrix = ()->

  # Layout Logics
  buildHierachy = ( item )->
    obj =
      component : item
      type : item.type
      x : 0
      y : 0

    if item.children

      obj.children = []
      children = item.children()

      sort = Defination[ item.type ]?.sortMethod
      if sort
        children = sort.call item, children

      for ch in children
        if Defination[ ch.type ]?.ignore then continue

        obj.children.push buildHierachy( ch )

    obj

  groupChildren = ( item )->
    if item.children
      groupChildren( ch ) for ch in item.children

    groupMethod = Defination[ item.type ]?.groupMethod || DefaultGroupMethod
    item.children = groupMethod.call item, item.children
    item

  arrangeGroup = ( item )->
    def = Defination[ item.type ] || {}

    if item.children
      for ch in item.children
        arrangeGroup( ch )

    arrangeMethod = def.arrangeMethod || DefaultArrangeMethod
    size = arrangeMethod.call item, item.children

    if def.margin
      size.width  += def.margin * 2
      size.height += def.margin * 2

      for ch in item.children
        ch.x += def.margin
        ch.y += def.margin

    item.width  = size.width
    item.height = size.height

    item

  AwsCanvasView.prototype.applyGeometry = ( item, parentX, parentY )->
    x = item.x + parentX
    y = item.y + parentY

    # Need to first arrange children, because we need to ensure sticky item's position.
    for ch in item.children
      @applyGeometry( ch, x, y )

    if item.component
      view = @getItem( item.component.id )
      if view
        # Special treatment for sticky item.
        if Defination[item.type]?.sticky
          x = -1
          y = -1
        view.applyGeometry( x, y, item.width, item.height )
    return

  AwsCanvasView.prototype.autoLayoutFully = ()->
    ###
    # 1. Build hierachy
    ###
    svgChildren = @__itemTopLevel.map ( item )-> item.model
    hierachy =
      type     : "SVG"
      children : ()-> svgChildren

    hierachy = buildHierachy( hierachy )

    ###
    # 2. Group children
    ###
    groupChildren( hierachy )

    ###
    # 3. Arrange Groups
    ###
    arrangeGroup( hierachy )

    ###
    # 4. Merge Position Info
    ###
    @applyGeometry( hierachy, 5, 3 )

    console.log hierachy
    return

  # Group Helpers
  GroupMForSubnet   = ( children )->
  GroupMForDbSubnet = ( children )->

  # Arrange Helpers
  ArrangeForVpc = ()->

  ArrangeForSvg = ( children )->
    newChs = []
    for ch in children
      if ch.type is "AWS.VPC.VPC_group"
        newChs.unshift( ch )
      else
        newChs.push( ch )

    DefaultArrangeMethod.call this, newChs

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
  Defination =
    "SVG" : {
      arrangeMethod : ArrangeForSvg
    }
    "AWS.VPC.CustomerGateway"  : {
      arrangeMethod : ArrangeVertical
    }
    "AWS.VPC.VPC" : {
      arrangeMethod : ArrangeVertical
      space         : 4
      sortMethod    : SortForVpc
      margin        : 2
      width         : 600
      height        : 600
    }
    "AWS.VPC.VPNGateway" : {
      sticky : true
    }
    "AWS.VPC.InternetGateway" : {
      sticky : true
    }

    "AWS.ELB_group" : {
      arrangeMethod : ArrangeHorizontal
      space   : 11
    }
    "AWS.ELB" : {
      width   : 9
      height  : 9
    }
    "AWS.VPC.RouteTable_group" : {
      arrangeMethod : ArrangeHorizontal
      space   : 4
    }
    "AWS.VPC.RouteTable":{
      width   : 9
      height  : 9
    }
    "AWS.EC2.AvailabilityZone_group" : {
      space : 4
    }
    "AWS.EC2.AvailabilityZone" : {
      # arrangeMethod : ArrangeMatrix
      margin : 2
      width  : 15
      height : 15
    }
    "AWS.RDS.DBSubnetGroup_group" : {
      space : 4
    }
    "AWS.RDS.DBSubnetGroup" : {
      margin : 2
      width  : 11
      height : 11
    }
    "AWS.AutoScaling.LaunchConfiguration" : {
      ignore : true
    }

    "AWS.VPC.NetworkInterface_group" : {
      space  : 4
    }
    "AWS.VPC.NetworkInterface" : {
      width  : 9
      height : 9
    }
    "AWS.EC2.Instance_group" : {
      space  : 4
    }
    "AWS.EC2.Instance" : {
      width  : 9
      height : 9
    }
    "AWS.AutoScaling.Group_group" : {
      space : 4
    }
    "AWS.AutoScaling.Group" : {
      width  : 13
      height : 13
    }
    "AWS.VPC.Subnet_group" : {
      space : 4
    }
    "AWS.VPC.Subnet" : {
      margin : 2
      width  : 11
      height : 11
    }
    "AWS.VPC.CustomerGateway" : {
      width  : 17
      height : 10
    }
    "AWS.RDS.DBInstance" : {
      width  : 9
      height : 9
    }

  null
