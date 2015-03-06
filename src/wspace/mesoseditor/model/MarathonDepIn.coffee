
define [ "constant", "ConnectionModel", "i18n!/nls/lang.js" ], ( constant, ConnectionModel, lang )->

  C = ConnectionModel.extend {

    type : "MarathonDepIn"

    directional : true

    portDefs : [
      {
        port1 :
          name : "app-dep-in"
          type : constant.RESTYPE.MRTHAPP
        port2 :
          name : "group-dep-out"
          type : constant.RESTYPE.MRTHGROUP
      }
      {
        port1 :
          name : "app-dep-in"
          type : constant.RESTYPE.MRTHAPP
        port2 :
          name : "app-dep-out"
          type : constant.RESTYPE.MRTHAPP
      }
      {
        port1 :
          name : "group-dep-in"
          type : constant.RESTYPE.MRTHGROUP
        port2 :
          name : "group-dep-out"
          type : constant.RESTYPE.MRTHGROUP
      }
      {
        port1 :
          name : "group-dep-in"
          type : constant.RESTYPE.MRTHGROUP
        port2 :
          name : "app-dep-out"
          type : constant.RESTYPE.MRTHAPP
      }
    ]

    constructor : ( p1Comp, p2Comp, attr, options )->

      if _.isString( p2Comp )
        p2 = @resolve( p1Comp, p2Comp )
        if not p2
          console.info "Cannot find dependency `#{p2Comp}` for", p1Comp
          return
        p2Comp = p2

      ConnectionModel.call this, p1Comp, p2Comp, attr, options

    absolutePath : ( target, relativePath )->
      if relativePath.indexOf( "../" ) is -1
        return relativePath

      relativePath = relativePath.replace(/\\/g,"\/")
      if relativePath.indexOf("../") is 0
        relativePath = target.path() + "/" + relativePath
      relativePath.replace(/\/[^/]+\/\.\./g,"")

    serialize : ( component_data, layout_data )->
      comp = component_data[ @port1Comp().id ]
      if not comp.resource.dependencies
        comp.resource.dependencies = []

      comp.resource.dependencies.push @port2Comp().path()
      return

    resolve : ( p1Comp, p2path )->
      p2path = @absolutePath( p1Comp, p2path )
      p2Comp = null
      p1Comp.design().eachComponent ( c )->
        if c.path() is p2path
          p2Comp = c
          return false
        true

      p2Comp

  }, {
    isConnectable : ( p1Comp, p2Comp )->
      for cn in p1Comp.connections()
        if cn.connectsTo( p2Comp.id )
          return false
      true
  }

  C
