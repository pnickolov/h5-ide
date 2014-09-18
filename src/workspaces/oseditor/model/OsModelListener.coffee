
define [ "./OsModelPort", "constant", "Design" ], ( OsModelPort, constant, Design )->

  Model = OsModelPort.extend {

    type : constant.RESTYPE.OSLISTENER
    newNameTmpl : "Listener-"

    defaults: ()->
      protocol : 'HTTP'
      port     : 80
      limit    : 1000
      ip       : "" # The same as OsModelPort's `ip`

    initialize : ( attr, options )->
      console.assert options.pool, "Pool must be specified when creating a listener"
      Asso = Design.modelClassForType( "OsListenerAsso" )
      new Asso( @, options.pool )

      if options.createByUser
        availableIP = Design.modelClassForType(constant.RESTYPE.OSPORT).getAvailableIP(@parent())
        @set('ip', availableIP) if availableIP
      
      return

    isAttached : ()-> true
    isVisual   : ()-> true
    isEmbedded : ()-> false

    serialize : ()->
      {
        layout : @generateLayout()
        component :
          name : @get 'name'
          type : @type
          uid  : @id
          resource :
            id                : @get 'appId'
            name              : @get 'name'
            pool_id           : @connectionTargets( 'OsListenerAsso' )[ 0 ].createRef 'id'
            subnet_id         : @parent().createRef( 'id' )
            connection_limit  : @get 'limit'
            protocol          : @get 'protocol'
            protocol_port     : @get 'port'

            port_id         : @get "portId"
            address         : @get "ip"
            security_groups : @connectionTargets("OsSgAsso").map ( sg )-> sg.createRef("id")
      }

  }, {

    handleTypes  : constant.RESTYPE.OSLISTENER

    deserialize : ( data, layout_data, resolve )->
      listener = new Model({
        id            : data.uid
        name          : data.resource.name
        appId         : data.resource.id

        limit         : data.resource.connection_limit
        port          : data.resource.protocol_port
        protocol      : data.resource.protocol

        parent        : resolve( MC.extractID( data.resource.subnet_id ) )
        x             : layout_data.coordinate[0]
        y             : layout_data.coordinate[1]

        portId : data.resource.port_id
        ip     : data.resource.address
      },{
        pool : resolve( MC.extractID( data.resource.pool_id ) )
      })

      SgAsso = Design.modelClassForType( "OsSgAsso" )
      for sg in data.resource.security_groups or []
        new SgAsso( listener, resolve( MC.extractID( sg ) ) )

      return
  }

  Model
