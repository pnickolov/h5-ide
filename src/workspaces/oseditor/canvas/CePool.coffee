
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsPool"
    ### env:dev:end ###
    type : constant.RESTYPE.OSPOOL

    parentType  : [ constant.RESTYPE.OSSUBNET ]
    defaultSize : [17,8]

    portPosMap : {
      "listener" : [ 2,  36, CanvasElement.constant.PORT_LEFT_ANGLE  ]
      "pool"     : [ 73, 36, CanvasElement.constant.PORT_RIGHT_ANGLE, 81, 36 ]
    }

    size : ()-> { width : 8, height : 8 }

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image  : "ide/icon/openstack/cvs-pool.png"
        imageX : 0
        imageY : 0
        imageW : 80
        imageH : 80
        label  : m.get "name"
      }).add([
        svg.use("port_right").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'listener'
          'data-tooltip' : lang.IDE.PORT_TIP_D
        })
        svg.use("port_right").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'pool'
          'data-tooltip' : lang.IDE.PORT_TIP_K
        })
      ])

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    render : ()->
      # Update label
      CanvasManager.setLabel @, @$el.children(".node-label")
  }, {
    createResource : ( type, attributes, options )->
      attributes.width = 8
      PoolModel = Design.modelClassForType constant.RESTYPE.OSPOOL
      pool = new PoolModel( $.extend({}, attributes, { x : attributes.x + 9 }), options )

      ListenerModel = Design.modelClassForType constant.RESTYPE.OSLISTENER
      listener = new ListenerModel( attributes, $.extend({ pool : pool }, options) )
      return
  }
