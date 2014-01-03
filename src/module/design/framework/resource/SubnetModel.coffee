
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

    connect : ( connection ) ->

      if connection.type is "RTB_Asso"
        # Remove previous association if there's any
        for cn in @connections( "RTB_Asso" )
          if cn isnt connection
            cn.remove()

      else if connection.type is "ACL_Asso"
        # Remove previous association if there's any
        for cn in @connections( "ACL_Asso" )
          if cn isnt connection
            cn.remove()
      null

    isRemovable : ()->
      if @connections("ElbSubnetAsso")
        return { error : lang.ide.CVS_MSG_ERR_DEL_LINKED_ELB }


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
        }) )

        $('#subnet_layer').append node

        # Move the group to right place
        CanvasManager.position node, @x(), @y()

      else
        CanvasManager.update( $( document.getElementById( @id ) ).children("text"), label )

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet

    deserialize : ( data, layout_data, resolve )->

      # RtbModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable )

      # # If we don't have a mainRT yet, then we don't deserialize this data
      # if not RtbModel.getMainRouteTable()
      #   return

      # AclModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl )

      # # If we don't have a DefaultAcl yet, then we don't deserialzie this data
      # if not AclModel.getDefaultAcl()
      #   return

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
