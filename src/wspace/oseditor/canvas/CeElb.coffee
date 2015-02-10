
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  # This class is only used to create pool and listener.

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsElb"
    ### env:dev:end ###
    type : constant.RESTYPE.OSELB

    parentType  : [ constant.RESTYPE.OSSUBNET ]
    defaultSize : [17,8]

  }, {
    createResource : ( type, attributes, options )->
      attributes.width = 8
      PoolModel = Design.modelClassForType constant.RESTYPE.OSPOOL
      pool = new PoolModel( $.extend({}, attributes, { x : attributes.x + 9 }), options )

      ListenerModel = Design.modelClassForType constant.RESTYPE.OSLISTENER
      listener = new ListenerModel( attributes, $.extend({ pool : pool }, options) )
      return
  }
