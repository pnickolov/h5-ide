
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSPOOL
    newNameTmpl : "Pool-"

    defaults: ()->
      protocol: 'HTTP'
      method: 'ROUND_ROBIN'

    initialize : ( attr, options )->
      if not attr.healthMonitors
        HmModel = Design.modelClassForType( constant.RESTYPE.OSHM )
        @attributes.healthMonitors = [ new HmModel() ]
      return

    ports : ()->
      ports = []
      for p in @connectionTargets("OsPoolMembership")
        if p.type is constant.RESTYPE.OSSERVER
          ports.push p.embedPort()
        else
          ports.push p
      ports

    addNewHm : (name)->
      MonitorModel = Design.modelClassForType( constant.RESTYPE.OSHM )
      if name
        monitor = new MonitorModel({name: name})
      else
        monitor = new MonitorModel()
      @get("healthMonitors").push( monitor )

      monitor

    getHm : ( id )->
      for hm in @get("healthMonitors")
        if hm.id is id
          return hm

      null

    removeHm : ( idOrModel )->
      for h, idx in @get("healthMonitors")
        if h is idOrModel or h.id is idOrModel
          @get("healthMonitors").splice( idx, 1 )
          h.remove()
          break

      return

    remove : ()->
      for hm in @get("healthMonitors")
        hm.remove()
      ComplexResModel.prototype.remove.apply this, arguments

    serialize : ()->
      member = _.map @connections( 'OsPoolMembership' ), ( c ) ->
        target = c.getOtherTarget( constant.RESTYPE.OSPOOL )
        target = target.embedPort() if target.type is constant.RESTYPE.OSSERVER

        {
          protocol_port : c.get 'port'
          address       : target.createRef 'fixed_ips.0.ip_address'
          weight        : c.get 'weight'
          id            : c.get 'appId'
        }

      {
        layout : @generateLayout()
        component :
          name : @get 'name'
          type : @type
          uid  : @id
          resource :
            id             : @get 'appId'
            name           : @get 'name'
            protocol       : @get 'protocol'
            lb_method      : @get 'method'
            subnet_id      : @parent().createRef 'id'
            healthmonitors : @get("healthMonitors").map (hm)-> hm.createRef 'id'
            member         : member
      }

  }, {

    handleTypes  : constant.RESTYPE.OSPOOL

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id        : data.uid
        name      : data.resource.name
        appId     : data.resource.id

        protocol  : data.resource.protocol
        method    : data.resource.lb_method

        parent    : resolve( MC.extractID( data.resource.subnet_id ) )
        x         : layout_data.coordinate[0]
        y         : layout_data.coordinate[1]

        healthMonitors : (data.resource.healthmonitors||[]).map (hmid)-> resolve( MC.extractID(hmid) )
      })
      return

    postDeserialize : ( data, layout_data )->
      # We can only asso `Pool <=> Port` in postDeserialize()
      # Because we can't know which port is embedded port in other phrase.
      design = Design.instance()
      pool   = design.component( data.uid )

      Membership = Design.modelClassForType("OsPoolMembership")

      for member in data.resource.member
        new Membership(
          pool,
          design.component( MC.extractID(member.address) ),
          {
            appId  : member.id
            weight : member.weight
            port   : member.protocol_port
          }
        )

      return
  }

  Model
