
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSPOOL
    newNameTmpl : "Pool-"

    defaults:
      protocol: 'HTTP'
      method: 'ROUND_ROBIN'

    getHm: -> @connectionTargets( 'OsMonitorUsage' )[ 0 ]

    ports : ()->
      @connectionTargets("")

    serialize : ()->
      member = _.map @connections( 'OsPoolMembership' ), ( c ) ->
        target = c.getOtherTarget( constant.RESTYPE.OSPOOL )
        target = target.embedPort() if target.type is constant.RESTYPE.OSSERVER

        {
          protocol_port : c.get 'port'
          address       : target.createRef 'fixed_ips.0.ip_address'
          weight        : c.get 'weight'
          id            : ''
        }

      component =
        name : @get 'name'
        type : @type
        uid  : @id
        resource :
          id   : @get 'appId'
          name : @get 'name'
          protocol         : @get 'protocol'
          lb_method        : @get 'method'
          subnet_id        : @parent().createRef 'id'
          healthmonitor_id : @connectionTargets( 'OsMonitorUsage' )[ 0 ].createRef 'id'
          member           : member

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSPOOL

    deserialize : ( data, layout_data, resolve )->
      pool = new Model({
        id        : data.uid
        name      : data.resource.name
        appId     : data.resource.id

        protocol  : data.resource.protocol
        method    : data.resource.lb_method

        parent    : resolve( MC.extractID( data.resource.subnet_id ) )
        x         : layout_data.coordinate[0]
        y         : layout_data.coordinate[1]
      })

      MonitorUsage = Design.modelClassForType( "OsMonitorUsage" )
      new MonitorUsage( pool, resolve(MC.extractID( data.resource.healthmonitor_id)) )
      return

    postDeserialize : ( data, layout_data )->
      # We can only asso `Pool <=> Port` in postDeserialize()
      # Because we can't know which port is embedded port in other phrase.
      design = Design.instance()
      pool   = design.component( data.uid )

      Membership = Design.modelClassForType("OsPoolMembership")

      for member in data.resource.member
        membership = new Membership( pool, design.component( MC.extractID(member.address) ) )
        membership.set { weight: member.weight, port: member.protocol_port }

      return
  }

  Model
