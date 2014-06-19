
define [
  "CloudResources"
  "Design"
  "../template/TplLeftPanel"
  "constant"
  'dhcp'
  'snapshotManager'
  'sslcert_manage'
  'sns_manage'
  'kp_manage'
  './AmiBrowser'
  'i18n!nls/lang.js'
  'ApiRequest'
  "backbone"
  'UI.radiobuttons'
], ( CloudResources, Design, LeftPanelTpl, constant, dhcpManager, snapshotManager, sslCertManager, snsManager, keypairManager, AmiBrowser, lang, ApiRequest )->

  # Update Left Panel when window size changes
  __resizeAccdTO = null
  $( window ).on "resize", ()->
    if __resizeAccdTO then clearTimeout(__resizeAccdTO)
    __resizeAccdTO = setTimeout ()->
      $(".OEPanelLeft").trigger("RECALC")
    , 150
    return

  Backbone.View.extend {

    events :
      "click .btn-fav-ami"           : "toggleFav"
      "click .HideOEPanelLeft"       : "toggleLeftPanel"
      "OPTION_CHANGE .AmiTypeSelect" : "changeAmiType"
      "click .BrowseCommunityAmi"    : "browseCommunityAmi"
      "click .ManageSnapshot"        : "manageSnapshot"
      "click .fixedaccordion-head"   : "updateAccordion"
      "RECALC"                       : "recalcAccordion"
      "mousedown .resource-item"     : "startDrag"
      "click .refresh-resource-panel": "refreshPanelData"
      'click .resources-dropdown-wrapper li' : 'resourcesMenuClick'

    initialize : (options)->
      @workspace = options.workspace

      region = @workspace.opsModel.get("region")
      @listenTo CloudResources( "MyAmi",               region ), "update", @updateMyAmiList
      @listenTo CloudResources( constant.RESTYPE.AZ,   region ), "update", @updateAZ
      @listenTo CloudResources( constant.RESTYPE.SNAP, region ), "update", @updateSnapshot

      design = @workspace.design
      @listenTo design, Design.EVENT.AzUpdated,      @updateDisableItems
      @listenTo design, Design.EVENT.AddResource,    @updateDisableItems
      @listenTo design, Design.EVENT.RemoveResource, @updateDisableItems

      @subEventForUpdateReuse()

      @__amiType = "QuickStartAmi" # QuickStartAmi | MyAmi | FavoriteAmi
      return

    render : ()->
      @setElement @workspace.view.$el.find(".OEPanelLeft").html LeftPanelTpl.panel({})

      @$el.toggleClass("hidden", @__leftPanelHidden || false)
      @recalcAccordion()

      @updateAZ()
      @updateSnapshot()
      @updateAmi()

      @updateDisableItems()
      @registerTemplate()
      @renderReuse()
      return

    reuseLc: Backbone.View.extend
      tagName: 'li'
      className: 'tooltip resource-item resource-icon-asg resource-reuse'
      inDom: false
      defaultAttr: ->
        'data-type': 'ASG'

      defaultData: ->
        that = @

        'option':
          lcId: that.model.id


      initialize: ( options ) ->
        options = {} if not options
        @parent = options.parent

        @settleElement options
        @bindEvent @model

      bindEvent: ( model ) ->
        @listenTo model, 'change', @render
        @listenTo model, 'destroy', ( lc ) ->
          if lc.__brothers.length
            @model = lc.__brothers[ 0 ]
            @stopListening()
            @bindEvent @model
            @settleElement {}
          else
            @remove()

      settleElement: ( options ) ->
        @$el.attr _.extend {}, options.attr, @defaultAttr()
        @$el.data _.extend {}, options.data, @defaultData()


      render: ->
        data = @model.toJSON()
        data.cachedAmi = @model.getAmi() if not data.cachedAmi
        @$el.html LeftPanelTpl.reuse_lc data

        if not @inDom
          @inDom = true
          ( @parent or @ ).$el.find(".resource-list-asg").append @el

        @


    renderReuse: ->
      allLc = Design.modelClassForType( constant.RESTYPE.LC ).allObjects()

      for lc in allLc
        if not lc.isClone()
          new @reuseLc({model:lc, parent : @}).render()

      @

    subEventForUpdateReuse: ->
      Design.on Design.EVENT.AddResource, ( resModel ) ->
        if resModel.type is constant.RESTYPE.LC and not resModel.isClone()
          new @reuseLc( model: resModel, parent: @ ).render()
      , @

    updateAZ : ()->
      if not @workspace.isAwake() then return
      region = @workspace.opsModel.get("region")

      @$el.find(".resource-list-az").html LeftPanelTpl.az(CloudResources( constant.RESTYPE.AZ, region ).where({category:region}) || [])
      @updateDisabledAz()
      return

    updateSnapshot : ()->
      if not @workspace.isAwake() then return
      region = @workspace.opsModel.get("region")
      @$el.find(".resource-list-snapshot").html LeftPanelTpl.snapshot(CloudResources( constant.RESTYPE.SNAP, region ).where({category:region}) || [])
      return

    changeAmiType : ( evt, attr )->
      @__amiType = attr || "QuickStartAmi"
      @updateAmi()

    updateAmi : ()->
      ms = CloudResources( @__amiType, @workspace.opsModel.get("region") ).getModels().sort ( a, b )->
        a = a.attributes
        b = b.attributes
        if a.osType is "windows" and b.osType isnt "windows" then return 1
        if a.osType isnt "windows" and b.osType is "windows" then return -1
        ca = a.osType
        cb = b.osType
        if ca is cb
          ca = a.architecture
          cb = b.architecture
          if ca is cb
            ca = a.name
            cb = b.name
        return if ca > cb then 1 else -1

      ms.fav = @__amiType is "FavoriteAmi"
      html = LeftPanelTpl.ami ms
      @$el.find(".resource-list-ami").html(html)

    registerTemplate: ->
      region = @workspace.opsModel.get('region')
      MC.template.bubbleAMIMongoInfo = (data)=>
        models = CloudResources(@__amiType,region).getModels()
        amiData = _.findWhere(models, {'id': data.id})?.toJSON()
        amiData.imageSize = amiData.imageSize || amiData.blockDeviceMapping[amiData.rootDeviceName]?.volumeSize
        amiData.instanceType = @addInstanceType(amiData).join(", ")
        MC.template.bubbleAMIInfo(amiData)

    addInstanceType: (ami)->
      region = @workspace.opsModel.get('region')
      if not ami or not region then return []
      data = App.model.getOsFamilyConfig( region )
      try
        data = data[ ami.osFamily ] || data[ constant.OS_TYPE_MAPPING[ami.osType] ]
        data = if ami.rootDeviceType  is "ebs" then data.ebs else data['instance store']
        data = if ami.architecture is "x86_64" then data["64"] else data["32"]
        data = data[ ami.virtualizationType || "paravirtual" ]
      catch e
        console.error "Invalid instance type list data", ami, App.model.getOsFamilyConfig( region )
        data = []
      data || []
    updateDisableItems : ()->
      if not @workspace.isAwake() then return
      @updateDisabledAz()
      @updateDisabledVpcRes()
      return

    updateDisabledAz : ()->
      $azs = @$el.find(".resource-list-az").children().removeClass("resource-disabled")
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
      return

    updateFavList   : ()-> if @__amiType is "FavoriteAmi" then @updateAmi()
    updateMyAmiList : ()-> if @__amiType is "MyAmi" then @updateAmi()

    toggleFav : ( evt )->
      $tgt = $( evt.currentTarget ).toggleClass("fav")
      amiCln = CloudResources( "FavoriteAmi", @workspace.opsModel.get("region") )
      if $tgt.hasClass("fav")
        amiCln.fav( $tgt.attr("data-id") )
      else
        amiCln.unfav( $tgt.attr("data-id") )
      return false

    toggleLeftPanel : ()->
      @__leftPanelHidden = @$el.toggleClass("hidden").hasClass("hidden")
      false

    updateAccordion : ( event, noAnimate ) ->
      $target    = $( event.currentTarget )
      $accordion = $target.closest(".accordion-group")

      if event.target and not $( event.target ).hasClass("fixedaccordion-head")
        return

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
      leftpane = @$el
      if not leftpane.length
        return

      $accordions = leftpane.children(".fixedaccordion").children()
      $accordion  = $accordions.filter(".expanded")
      if $accordion.length is 0
        $accordion = $accordions.eq( @__openedAccordion || 0 )

      $target = $accordion.removeClass( 'expanded' ).children( '.fixedaccordion-head' )
      this.updateAccordion( { currentTarget : $target[0] }, true )

    browseCommunityAmi : ()->
      region = @workspace.opsModel.get("region")
      # Start listening fav update.
      @listenTo CloudResources( "FavoriteAmi", region ), "update", @updateFavList

      amiBrowser = new AmiBrowser({ region : region })
      amiBrowser.onClose = ()=>
        @stopListening CloudResources( "FavoriteAmi", region ), "update", @updateFavList
      return false

    manageSnapshot : ()-> new snapshotManager().render()

    refreshPanelData : ( evt )->
      $tgt = $( evt.currentTarget )
      if $tgt.hasClass("reloading") then return

      $tgt.addClass("reloading")
      region = @workspace.opsModel.get("region")
      Q.all([
        CloudResources( "MyAmi", region ).fetchForce()
        CloudResources( constant.RESTYPE.SNAP, region ).fetchForce()
      ]).done ()-> $tgt.removeClass("reloading")
      return

    resourcesMenuClick : (event) ->
          $currentDom = $(event.currentTarget)
          currentAction = $currentDom.data('action')
          switch currentAction
              when 'keypair'
                  new keypairManager().render()
              when 'snapshot'
                  new snapshotManager().render()
              when 'sns'
                  new snsManager().render()
              when 'sslcert'
                  new sslCertManager().render()
              when 'dhcp'
                  (new dhcpManager()).manageDhcp()
    # Copied and enhanced from MC.canvas.js
    startDrag : ( evt )->
      if evt.button isnt 0 then return false
      $tgt = $( evt.currentTarget )
      if $tgt.hasClass("resource-disabled") then return false
      if evt.target && $( evt.target ).hasClass("btn-fav-ami") then return

      type = constant.RESTYPE[ $tgt.attr("data-type") ]
      console.assert( type )

      # Insert Shadow
      $("<div id='ResourceDragItem'></div><div id='overlayer' class='grabbing'></div>").appendTo( document.body )
      tgtOffset = $tgt.offset()
      $item = $("#ResourceDragItem")
        .html( $tgt.html() )
        .attr("class", $tgt.attr("class") )
        .css({
          'top'  : tgtOffset.top
          'left' : tgtOffset.left
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
            drop_zone_offset = $changeAmiZone.offset()
            drop_zone_data = {
              'x1' : drop_zone_offset.left
              'x2' : drop_zone_offset.left + $changeAmiZone.width()
              'y1' : drop_zone_offset.top
              'y2' : drop_zone_offset.top + $changeAmiZone.height()
            }


        component_size = MC.canvas.GROUP_DEFAULT_SIZE[ type ]
        node_type      = "group"
        placeOffsetX   = 0
        placeOffsetY   = 0
        if not component_size
          component_size = MC.canvas.COMPONENT_SIZE[ type ]
          node_type = "node"
          placeOffsetX   = 8
          placeOffsetY   = 8

        if type is constant.RESTYPE.INSTANCE then placeOffsetY = 0
        if type is constant.RESTYPE.ASG      then placeOffsetX = -8

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
          'offsetX'        : evt.pageX - tgtOffset.left
          'offsetY'        : evt.pageY - tgtOffset.top
          "placeOffsetY"   : placeOffsetY
          "placeOffsetX"   : placeOffsetX
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
        (evt.pageX - event_data.offsetX - event_data.placeOffsetX - canvas_offset.left) / 10 * event_data.scale
        (evt.pageY - event_data.offsetY - event_data.placeOffsetY - canvas_offset.top)  / 10 * event_data.scale
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
        top  : evt.pageY - event_data.offsetY
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

      event_data = event.data

      if event_data.drop_zone_data &&
        event.pageX > event_data.drop_zone_data.x1 &&
        event.pageX < event_data.drop_zone_data.x2 &&
        event.pageY > event_data.drop_zone_data.y1 &&
        event.pageY < event_data.drop_zone_data.y2
          event_data.drop_zone.removeClass("hover").trigger("drop", $(event.data.target).data('option').imageId)
          $item.remove()
          return false


      node_type      = event_data.node_type
      target_type    = event_data.target_type
      canvas_offset  = event_data.canvas_offset
      node_option    = event_data.target.data('option') || {}
      component_size = event_data.comp_size
      coordinate     = {
        x : (event.pageX - event_data.offsetX - event_data.placeOffsetX - canvas_offset.left) / 10 * event_data.scale
        y : (event.pageY - event_data.offsetY - event_data.placeOffsetY - canvas_offset.top)  / 10 * event_data.scale
      }

      if coordinate.x < 0 or coordinate.y < 0
        $item.remove()
        return

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
