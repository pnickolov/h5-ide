
define [ "constant", "./MarathonDepIn", "i18n!/nls/lang.js" ], ( constant, MarathonDepIn, lang )->

  C = MarathonDepIn.extend {

    type : "MarathonDepOut"
    directional : true
    portDefs : [
      {
        port1 :
          name : "app-dep-out"
          type : constant.RESTYPE.MRTHAPP
        port2 :
          name : "group-dep-in"
          type : constant.RESTYPE.MRTHGROUP
      }
      {
        port1 :
          name : "app-dep-out"
          type : constant.RESTYPE.MRTHAPP
        port2 :
          name : "app-dep-in"
          type : constant.RESTYPE.MRTHAPP
      }
      {
        port1 :
          name : "group-dep-out"
          type : constant.RESTYPE.MRTHGROUP
        port2 :
          name : "group-dep-in"
          type : constant.RESTYPE.MRTHGROUP
      }
      {
        port1 :
          name : "group-dep-out"
          type : constant.RESTYPE.MRTHGROUP
        port2 :
          name : "app-dep-in"
          type : constant.RESTYPE.MRTHAPP
      }
    ]

    serialize : ( component_data, layout_data )->
      comp = component_data[ @port2Comp().id ]
      if not comp.resource.dependencies
        comp.resource.dependencies = []

      comp.resource.dependencies.push @port1Comp().path()
      return
  }

  C
