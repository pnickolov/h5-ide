
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSPORT
    newNameTmpl : "Port-"

    server : ()-> @connectionTargets("OsPortUsage")[0]

    isEmbedded : ()-> @server() and @server().embedPort() is @
    isVisual   : ()-> !@isEmbedded()

    initialize: ()->
      console.log ("Initializing....")
      @bindEvent()

    bindEvent: ()->
      console.log "Destroying"
      @on 'destroy', @removeReference()

    removeReference: ->
      #@server().removePort()

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id   : @get("appId")
          name : @get("name")

          admin_state_up  : ""
          mac_address     : ""
          fixed_ips       : []
          security_groups : []
          network_id      : ""

      { component : component }



    updateFip: (ip)->
      console.log "Updating Fixed Ip"
      #todo: Update Floating Ips
     # if not @isEmbedded() then return false
      server = @server()
      subnet = server.getSubnetRef()
      console.log( server, subnet )
      @set("fixed_ips", [{
        subnet_id: ""
        ip_address: ip
      }])

  }, {

    handleTypes  : constant.RESTYPE.OSPORT

    deserialize : ( data, layout_data, resolve )->
      port = new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id

        parent : resolve( MC.extractID( data.resource.fixed_ips[0].subnet_id) )

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      SgAsso = Design.modelClassForType( "OsSgAsso" )
      for sg in data.resource.security_groups
        new SgAsso( port, resolve( MC.extractID( sg ) ) )

      return
  }

  Model
