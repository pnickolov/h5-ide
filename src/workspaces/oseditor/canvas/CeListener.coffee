
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsListener"
    ### env:dev:end ###
    type : constant.RESTYPE.OSLISTENER

    parentType  : [ constant.RESTYPE.OSSUBNET ]
    defaultSize : [8,8]

    portPosMap : {
      "listener" : [ 78, 35, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image  : "ide/icon/cvs-igw.png"
        imageX : 9
        imageY : 11
        imageW : 70
        imageH : 53
        label  : m.get "name"
      }).add([
        svg.use("port_right").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'listener'
          'data-tooltip' : lang.IDE.PORT_TIP_D
        })
      ])

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    render : ()->
      # Update label
      CanvasManager.setLabel @, @$el.children(".node-label")
  }
