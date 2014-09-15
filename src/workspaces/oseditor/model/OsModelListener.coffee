
define [ "./OsModelPort", "constant", "Design" ], ( OsModelPort, constant, Design )->

  Model = OsModelPort.extend {

    type : constant.RESTYPE.OSLISTENER
    newNameTmpl : "Listener-"

    defaults:
      protocol : 'HTTP'
      port     : 80
      limit    : 1000
      ip       : "" # The same as OsModelPort's `ip`

    embedPort  : ()-> @connectionTargets("OsPortUsage")[0]
    isAttached : ()-> true

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
            security_groups : []
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
      })

      Asso = Design.modelClassForType( "OsListenerAsso" )
      new Asso( listener, resolve(MC.extractID( data.resource.pool_id )) )
      return
  }

  Model
