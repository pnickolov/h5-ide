
define [ "./CanvasBundle", "constant" ], ( CanvasView, constant )->

  AwsCanvasView = CanvasView.extend {
    recreateStructure : ()->
      @svg.clear().add([
        @svg.group().classes("layer_vpc")
        @svg.group().classes("layer_az")
        @svg.group().classes("layer_line")
        @svg.group().classes("layer_subnet")
        @svg.group().classes("layer_asg")
        @svg.group().classes("layer_sgline")
        @svg.group().classes("layer_node")
      ])
      return

    appendVpc    : ( svgEl )-> @__appendSvg(svgEl, ".layer_vpc")
    appendAz     : ( svgEl )-> @__appendSvg(svgEl, ".layer_az")
    appendSubnet : ( svgEl )-> @__appendSvg(svgEl, ".layer_subnet")
    appendAsg    : ( svgEl )-> @__appendSvg(svgEl, ".layer_asg")
    appendSgline : ( svgEl )-> @__appendSvg(svgEl, ".layer_sgline")

    fixConnection : ( coord, initiator, target )->
      if target.type is constant.RESTYPE.ELB and ( initiator.type is constant.RESTYPE.INSTANCE or initiator.type is constant.RESTYPE.LC )
        if coord.x < target.pos().x + target.size().width / 2
          toPort = "elb-sg-out"
        else
          toPort = "elb-sg-in"

      else if target.type is constant.RESTYPE.ASG or target.type is "ExpandedAsg"
        target = target.getLc()
        if target then target = @getItem( target.id )

      {
        toPort : toPort
        target : target
      }
  }

  AwsCanvasView
