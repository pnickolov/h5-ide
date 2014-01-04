
define [ "constant",
         "Design",
         "../GroupModel",
         "CanvasManager",
         "../connection/RtbAsso",
         "../connection/AclAsso",
         "i18n!nls/lang.js"
], ( constant, Design, GroupModel, CanvasManager, RtbAsso, AclAsso, lang )->

  Model = GroupModel.extend {

    type    : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
    newNameTmpl : "subnet"

    defaults :
      x      : 2
      y      : 2
      width  : 17
      height : 17
      cidr   : ""

    initialize : ()->
      # Draw the node
      @draw(true)

      # Connect to the MainRT automatically
      RtbModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable )
      new RtbAsso( this, RtbModel.getMainRouteTable(), { implicit : true } )

      # Connect to the DefaultACL automatically
      Acl = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl )
      new AclAsso( this, Acl.getDefaultAcl() )
      null

    setCIDR : ( cidr )->

      # TODO : Update all Eni's IP
      #if not MC.aws.vpc.updateAllSubnetCIDR( cidr, @get("cidr") )
      #  return false

      @set("cidr", cidr)
      @draw()

      null

    setAcl : ( uid )->
      new AclAsso( this, Design.instance().component( uid ) )
      null

    disconnect : ( connection )->
      if connection.type is "RTB_Asso"
        # When an RtbAsso is disconnected create a connection between this subnet and
        RtbModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable )
        new RtbAsso( this, RtbModel.getMainRouteTable(), { implicit : true } )

    isReparentable : ( newParent )->
      for child in @children()
        if child.type isnt constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance and child.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
          continue

        for attach in child.connectionTargets( "EniAttachment" )
          if attach.parent() isnt this
            return lang.ide.CVS_MSG_ERR_MOVE_ATTACHED_ENI

      true

    isRemovable : ()->
      if @connections("ElbSubnetAsso").length > 0
        return { error : lang.ide.CVS_MSG_ERR_DEL_LINKED_ELB }

      true

    draw : ( isCreate )->

      label = "#{@get('name')} (#{ @get('cidr')})"

      if isCreate
        node = @createNode( label )

        portX = @width()  * MC.canvas.GRID_WIDTH + 4
        portY = @height() * MC.canvas.GRID_HEIGHT / 2 - 5

        node.append( Canvon.path( MC.canvas.PATH_D_PORT ).attr({
          'class'      : 'port port-gray port-subnet-assoc-in'
          'id'         : @id + '_port-subnet-assoc-in'
          'transform'  : 'translate(-12, ' + portY + ')' # port poition
          'data-angle' : MC.canvas.PORT_LEFT_ANGLE # port angle
          'data-name'     : 'subnet-assoc-in'
          'data-position' : 'left'
          'data-type'     : 'association'
          'data-direction': 'in'
        }) )

        node.append( Canvon.path( MC.canvas.PATH_D_PORT ).attr({
          'class'      : 'port port-gray port-subnet-assoc-out'
          'id'         : @id + '_port-subnet-assoc-out'
          'transform'  : 'translate(' + portX + ', ' + portY + ')'
          'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
          'data-name'     : 'subnet-assoc-out'
          'data-position' : 'right'
          'data-type'     : 'association'
          'data-direction': 'out'
        }) )

        $('#subnet_layer').append node

        # Move the group to right place
        CanvasManager.position node, @x(), @y()

      else
        CanvasManager.update( $( document.getElementById( @id ) ).children("text"), label )

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet

    deserialize : ( data, layout_data, resolve )->

      new Model({

        id   : data.uid
        name : data.name
        cidr : data.resource.CidrBlock

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]

        parent : resolve( MC.extractID(data.resource.AvailabilityZone) )
      })

      null
  }

  Model
