
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSPOOL
    newNameTmpl : "Pool-"

    ports : ()->
      @connectionTargets("")

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id   : @get("appId")
          name : @get("name")
          protocol         : ""
          lb_algorithm     : ""
          subnet_id        : ""
          healthmonitor_id : ""
          member           : []

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSPOOL

    deserialize : ( data, layout_data, resolve )->
      pool = new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id

        parent : resolve( MC.extractID( data.resource.subnet_id ) )
        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
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
        new Membership( pool, design.component( MC.extractID(member.address) ) )

      return
  }

  Model
