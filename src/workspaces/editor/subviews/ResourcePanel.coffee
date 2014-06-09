
define [
  "CloudResources"
  "Design"
  "../template/TplLeftPanel"
  "constant"
  "backbone"
], ( CloudResources, Design, LeftPanelTpl, constant )->

  # Update Left Panel when window size changes
  __resizeAccdTO = null
  $( window ).on "resize", ()->
    if __resizeAccdTO then clearTimeout(__resizeAccdTO)
    __resizeAccdTO = setTimeout ()->
      $("#OEPanelLeft").trigger("RECALC")
    , 150
    return

  Backbone.View.extend {

    events :
      "click #HideOEPanelLeft"       : "toggleLeftPanel"
      "OPTION_CHANGE #AmiTypeSelect" : "changeAmiType"
      "click #BrowseCommunityAmi"    : "browseCommunityAmi"
      "click #ManageSnapshot"        : "manageSnapshot"
      "click #RefreshLeftPanel"      : "refreshPanelDataData"
      "click .fixedaccordion-head"   : "updateAccordion"
      "RECALC"                       : "recalcAccordion"
      "mousedown .resource-item"     : "startDrag"

    initialize : (options)->
      @workspace = options.workspace
      region = @workspace.opsModel.get("region")
      @listenTo CloudResources( constant.RESTYPE.AZ,   region ), "update", @updateAZ
      @listenTo CloudResources( constant.RESTYPE.SNAP, region ), "update", @updateSnapshot

      @listenTo @workspace.design, Design.EVENT.AzUpdated,      @updateDisableItems
      @listenTo @workspace.design, Design.EVENT.AddResource,    @updateDisableItems
      @listenTo @workspace.design, Design.EVENT.RemoveResource, @updateDisableItems
      return

    render : ()->
      @setElement $("#OEPanelLeft").html LeftPanelTpl.panel({})
      $("#OEPanelLeft").toggleClass("hidden", @__rightPanelHidden || false)
      @recalcAccordion()

      @updateAZ()
      @updateSnapshot()

      @updateDisableItems()
      return

    updateAZ : ()->
      if not @workspace.isAwake() then return
      region = @workspace.opsModel.get("region")

      $("#OEPanelLeft").find(".resource-list.availability-zone").html LeftPanelTpl.az(CloudResources( constant.RESTYPE.AZ, region ).where({category:region}) || [])
      @updateDisabledAz()
      return

    updateSnapshot : ()->
      if not @workspace.isAwake() then return
      region = @workspace.opsModel.get("region")
      $("#OEPanelLeft").find(".resource-list.resoruce-snapshot").html LeftPanelTpl.snapshot(CloudResources( constant.RESTYPE.SNAP, region ).where({category:region}) || [])
      return

    updateDisableItems : ()->
      if not @workspace.isAwake() then return
      @updateDisabledAz()
      @updateDisabledVpcRes()
      return

    updateDisabledAz : ()->
      $azs = @$el.find(".availability-zone").children().removeClass("resource-disabled")
      for az in @workspace.design.componentsOfType( constant.RESTYPE.AZ )
        azName = az.get("name")
        for i in $azs
          if $(i).text().indexOf(azName) != -1
            $(i).addClass("resource-disabled")
            break
      return

    updateDisabledVpcRes : ()->
      $ul = @$el.find(".resource-icon-igw").parent()
      design = @workspace.design
      $ul.children(".resource-icon-igw").toggleClass("resource-disabled", design.componentsOfType(constant.RESTYPE.IGW).length > 0)
      $ul.children(".resource-icon-vgw").toggleClass("resource-disabled", design.componentsOfType(constant.RESTYPE.VGW).length > 0)
      $ul.children(".resource-icon-cgw").toggleClass("resource-disabled", design.componentsOfType(constant.RESTYPE.CGW).length > 0)
      return


    clearDom : ()->
      @$el = null
      return

    toggleLeftPanel : ()->
      @__leftPanelHidden = $("#OEPanelLeft").toggleClass("hidden").hasClass("hidden")
      false

    updateAccordion : ( event, noAnimate ) ->
      $target    = $( event.currentTarget )
      $accordion = $target.closest(".accordion-group")

      if $accordion.hasClass "expanded"
        return false

      @__openedAccordion = $accordion.index()

      $expanded = $accordion.siblings ".expanded"
      $body     = $accordion.children ".accordion-body"

      $accordionWrap   = $accordion.closest ".fixedaccordion"
      $accordionParent = $accordionWrap.parent()

      $visibleAccordion = $accordionWrap.children().filter ()->
        $(this).css('display') isnt 'none'

      height = $accordionParent.outerHeight() - 39 - $visibleAccordion.length * $target.outerHeight()

      $body.outerHeight height

      if noAnimate
        $accordion.addClass "expanded"
        $expanded.removeClass "expanded"
        return false

      $body.slideDown 200, ()->
        $accordion.addClass "expanded"

      $expanded.children(".accordion-body").slideUp 200, ()->
        $expanded.closest(".accordion-group").removeClass "expanded"
      false

    recalcAccordion : () ->
      leftpane = $("#OEPanelLeft")
      if not leftpane.length
        return

      $accordions = leftpane.children(".fixedaccordion").children()
      $accordion  = $accordions.filter(".expanded")
      if $accordion.length is 0
        $accordion = $accordions.eq( @__openedAccordion || 0 )

      $target = $accordion.removeClass( 'expanded' ).children( '.fixedaccordion-head' )
      this.updateAccordion( { currentTarget : $target[0] }, true )

    changeAmiType : ()->

    browseCommunityAmi : ()->

    manageSnapshot : ()->

    refreshPanelData : ()->

    # Copied and enhanced from MC.canvas.js
    startDrag : ( evt )->
      $tgt = $( evt.currentTarget )
      if $tgt.hasClass("resource-disabled") then return false

      type = constant.RESTYPE[ $tgt.attr("data-type") ]
      console.assert( type )

      # Insert Shadow
      $("<div id='ResourceDragItem'></div><div id='overlayer' class='grabbing'></div>").appendTo( document.body )
      $item = $("#ResourceDragItem")
        .html( $tgt.html() )
        .attr("class", $tgt.attr("class") )
        .css({
          'top'  : evt.pageY - evt.offsetY
          'left' : evt.pageX - evt.offsetX
        })
      setTimeout ()->
        $item.addClass("add-to-dom")
      , 10

      # Update Svg
      if type is constant.RESTYPE.VOL
        Canvon('.AWS-EC2-Instance, .AWS-AutoScaling-LaunchConfiguration').addClass('attachable')
        $(document).on({
          'mousemove' : MC.canvas.volume.mousemove
          'mouseup'   : MC.canvas.volume.mouseup
        }, {
          'target'        : $tgt
          'canvas_offset' : $canvas.offset()
          'canvas_body'   : $('#canvas_body')
          'shadow'        : $item
          'action'        : 'add'
        })
      else
        target_group_type = MC.canvas.MATCH_PLACEMENT[ type ]
        if target_group_type
          Canvon('.' + target_group_type.join(',').replace(/\./ig, '-').replace(/,/ig, ',.')).addClass('dropable-group')

        if type is constant.RESTYPE.INSTANCE
          $changeAmiZone = $("#changeAmiDropZone")
          if $changeAmiZone.is(":visible")
            drop_zone_offset = drop_zone.offset()
            drop_zone_data = {
              'x1' : drop_zone_offset.left
              'x2' : drop_zone_offset.left + drop_zone.width()
              'y1' : drop_zone_offset.top
              'y2' : drop_zone_offset.top + drop_zone.height()
            }


        component_size = MC.canvas.COMPONENT_SIZE[ type ]
        node_type      = "node"
        if not component_size
          node_type = "group"
          component_size = MC.canvas.GROUP_DEFAULT_SIZE[ type ]

        $(document).on({
          'mousemove.SidebarDrag' : @onDragMove
          'mouseup.SidebarDrag'   : @onDragStop
        }, {
          'target_type'    : type
          'canvas_offset'  : $canvas.offset()
          'drop_zone'      : $changeAmiZone
          'drop_zone_data' : drop_zone_data
          "comp_size"      : component_size
          "node_type"      : node_type
          'offsetX'        : evt.offsetX
          'offsetY'        : evt.offsetY
          'target'         : $tgt
          "scale"          : $canvas.scale()
        })

        $('#canvas_body').addClass('node-dragging')


      # Cleanup Canvas
      MC.canvas.volume.close()
      MC.canvas.event.clearSelected()

      false

    onDragMove : ( evt )->
      Canvon('.match-dropable-group').removeClass('match-dropable-group')

      event_data    = evt.data
      canvas_offset = event_data.canvas_offset
      match_place = MC.canvas.isMatchPlace(
        null
        event_data.target_type
        event_data.node_type
        (evt.pageX - event_data.offsetX + 10 - canvas_offset.left) / 10 * event_data.scale
        (evt.pageY - event_data.offsetY + 10 - canvas_offset.top)  / 10 * event_data.scale
        event_data.comp_size[0]
        event_data.comp_size[1]
      )

      if match_place.is_matched
        Canvon('#' + match_place.target).addClass('match-dropable-group')

      # For change AMI hover effect
      if event_data.drop_zone_data
        hover = event.pageX > event_data.drop_zone_data.x1 &&
          event.pageX < event_data.drop_zone_data.x2 &&
          event.pageY > event_data.drop_zone_data.y1 &&
          event.pageY < event_data.drop_zone_data.y2

        event_data.drop_zone.toggleClass("hover", hover)

      $("#ResourceDragItem").css {
        top : evt.pageY - event_data.offsetY
        left : evt.pageX - event_data.offsetX
      }
      false

    onDragStop : ( event )->
      $("#overlayer").remove()
      $item = $("#ResourceDragItem")

      # Cleanup
      Canvon('.dropable-group').removeClass('dropable-group')
      Canvon('.match-dropable-group').removeClass('match-dropable-group')
      $('#canvas_body').removeClass('node-dragging')
      $(document).off('mousemove.SidebarDrag').off('mouseup.SidebarDrag')

      $zone = $(document.elementFromPoint(event.pageX, event.pageY)).closest("#changeAmiDropZone")
      if $zone.length > 0
        $zone.removeClass("hover").trigger("drop", $(event.data.target).data('option').imageId)
        $item.remove()
        return false

      event_data     = event.data
      node_type      = event_data.node_type
      target_type    = event_data.target_type
      canvas_offset  = event_data.canvas_offset
      node_option    = event_data.target.data('option') || {}
      component_size = event_data.comp_size
      coordinate     = {
        x : (event.pageX - event_data.offsetX + 10 - canvas_offset.left) / 10 * event_data.scale
        y : (event.pageY - event_data.offsetY + 10 - canvas_offset.top)  / 10 * event_data.scale
      }
      if coordinate.x > 0 && coordinate.y > 0
        if node_type is "node"
          if target_type is constant.RESTYPE.IGW || target_type is constant.RESTYPE.VGW
            vpc_id         = $('.AWS-VPC-VPC').attr('id')
            vpc_item       = $canvas( vpc_id )
            vpc_coordinate = vpc_item.position()
            vpc_size       = vpc_item.size()
            node_option.groupUId = vpc_id

            if coordinate.y > vpc_coordinate[1] + vpc_size[1] - component_size[1]
              coordinate.y = vpc_coordinate[1] + vpc_size[1] - component_size[1]
            if coordinate.y < vpc_coordinate[1]
              coordinate.y = vpc_coordinate[1]

            if target_type is constant.RESTYPE.IGW
              coordinate.x = vpc_coordinate[0] - (component_size[1] / 2)
            else
              coordinate.x = vpc_coordinate[0] + vpc_size[0] - (component_size[1] / 2)

            $canvas.add(target_type, node_option, coordinate)
          else
            match_place = MC.canvas.isMatchPlace(
              null
              target_type
              node_type
              coordinate.x
              coordinate.y
              component_size[0]
              component_size[1]
            )

            if match_place.is_matched
              node_option.groupUId = match_place.target
              new_node_id = $canvas.add(target_type, node_option, coordinate)
              if new_node_id then MC.canvas.select(new_node_id)
            else
              $canvas.trigger("CANVAS_PLACE_NOT_MATCH", {'type':target_type})
        else
          match_place = MC.canvas.isMatchPlace(
            null
            target_type
            node_type
            coordinate.x
            coordinate.y
            component_size[0]
            component_size[1]
          )
          areaChild = MC.canvas.areaChild(
            null
            target_type
            coordinate.x
            coordinate.y
            coordinate.x + component_size[0]
            coordinate.y + component_size[1]
          )
          if match_place.is_matched
            if areaChild.length is 0 and MC.canvas.isBlank(
                ""
                target_type
                'group'
                # Enlarge a little bit to make the drop place correctly.
                coordinate.x - 1,
                coordinate.y - 1,
                component_size[0] + 2
                component_size[1] + 2
              )
              node_option.groupUId = match_place.target
              new_node_id = $canvas.add(target_type, node_option, coordinate)
              if !($canvas.hasVPC() && target_type is constant.RESTYPE.AZ )
                MC.canvas.select(new_node_id)
            else
              $canvas.trigger("CANVAS_PLACE_OVERLAP")
          else
            $canvas.trigger("CANVAS_PLACE_NOT_MATCH", {type:target_type})

      if target_type is constant.RESTYPE.IGW or target_type is constant.RESTYPE.VGW
        $item.animate({
          'left'    : coordinate.x * 10 + canvas_offset.left
          'top'     : coordinate.y * 10 + canvas_offset.top
          'opacity' : 0
        }, ()-> $item.remove() )
      else
        $item.remove()

      false

  }
