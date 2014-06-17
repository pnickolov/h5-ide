
define [
  "CloudResources"
  "Design"
  "../template/TplLeftPanel"
  "constant"
  "ResDiff"
  'dhcp'
  'snapshotManager'
  'sslcert_manage'
  'sns_manage'
  'kp_manage'
  'jsona'
  'jsonb'
  'component/amis/main'
  'i18n!nls/lang.js'
  'ApiRequest'
  "backbone"
  'UI.radiobuttons'
], ( CloudResources, Design, LeftPanelTpl, constant, ResDiff, dhcpManager, snapshotManager, sslCertManager, snsManager, keypairManager, oldAppJSON, newAppJSON, amiBrowser, lang, ApiRequest )->

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
      "click .HideOEPanelLeft"       : "toggleLeftPanel"
      "OPTION_CHANGE .AmiTypeSelect" : "changeAmiType"
      "click .BrowseCommunityAmi"    : "browseCommunityAmi"
      "click .ManageSnapshot"        : "manageSnapshot"
      "click .RefreshLeftPanel"      : "refreshPanelDataData"
      "click .fixedaccordion-head"   : "updateAccordion"
      "RECALC"                       : "recalcAccordion"
      "mousedown .resource-item"     : "startDrag"
      "click .refresh-resource-panel": "refreshResourcePanel"
      'click .resources-dropdown-wrapper li' : 'resourcesMenuClick'

    initialize : (options)->
      @workspace = options.workspace
      region = @workspace.opsModel.get("region")
      @listenTo CloudResources( constant.RESTYPE.AZ,   region ), "update", @updateAZ
      @listenTo CloudResources( constant.RESTYPE.SNAP, region ), "update", @updateSnapshot

      @listenTo @workspace.design, Design.EVENT.AzUpdated,      @updateDisableItems
      @listenTo @workspace.design, Design.EVENT.AddResource,    @updateDisableItems
      @listenTo @workspace.design, Design.EVENT.RemoveResource, @updateDisableItems

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

        @$el.attr _.extend {}, options.attr, @defaultAttr()
        @$el.data _.extend {}, options.data, @defaultData()

        @listenTo @model, 'change', @render
        @listenTo @model, 'destroy', @remove

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
        new @reuseLc({model:lc, parent : @}).render()

      @

    subEventForUpdateReuse: ->
      Design.on Design.EVENT.AddResource, ( resModel ) ->
        if resModel.type is constant.RESTYPE.LC
          new @reuseLc( model: resModel, parent: @ ).render()
      , @

    refreshResourcePanel : () ->

      resDiff = new ResDiff({
        old: oldAppJSON,
        new: newAppJSON
      })
      resDiff.render()

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
        MC.template.bubbleAMIInfo(amiData)

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


    toggleLeftPanel : ()->
      @__leftPanelHidden = @$el.toggleClass("hidden").hasClass("hidden")
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
      searchCommunityAmiCurrent = @searchCommunityAmiCurrent.bind @
      faveCommunityAmi = @faveCommunityAmi.bind @

      amisModal = amiBrowser.loadModule()
      amisModal.on 'close', ->
        console.debug 'it works'

      $(document).off 'keypress',   '#community-ami-input'
      $(document).off 'click',      '#btn-search-ami'
      $(document).off 'click',      '.toggle-fav'
      $(document).on 'keypress',   '#community-ami-input', searchCommunityAmiCurrent
      $(document).on 'click',      '#btn-search-ami',      searchCommunityAmiCurrent
      $(document).on 'click',      '.toggle-fav',          faveCommunityAmi
      @searchCommunityAmi()

    faveCommunityAmi: (event)->
      amiElem = $(event.target)
      that = this
      favAmis = CloudResources "FavoriteAmi", that.workspace.opsModel.get("region")
      promise = null
      if amiElem.hasClass('faved')
        promise = favAmis.unfav(amiElem.data('id'))
      else
        promise = favAmis.fav(amiElem.data("id"))
      promise?.then ->
        notification 'info', if not amiElem.hasClass("faved") then lang.ide.RES_MSG_INFO_ADD_AMI_FAVORITE_SUCCESS else lang.ide.RES_MSG_INFO_REMVOE_FAVORITE_AMI_SUCCESS
        amiElem.toggleClass('faved')
      , ->
        notification 'error', if not amiElem.hasClass("faved") then lang.ide.RES_MSG_ERR_ADD_FAVORITE_AMI_FAILED else lang.ide.RES_MSG_ERR_REMOVE_FAVORITE_AMI_FAILED

    searchCommunityAmi : (pageNum, perPage)->
      pageNum = pageNum || 1
      @renderAmiLoading()
      name = $("#community-ami-input").val()
      platform = $('#selectbox-ami-platform').find('.selected').data('id')
      isPublic = 'true'
      architecture = '32-bit'
      rootDeviceType = "EBS"
      if $('#filter-ami-type').find('.active').length is 1
        visibility      = radiobuttons.data($('#filter-ami-type'))
        isPublic = if visibility is 'Private' then 'false' else 'true'
      else if $('#filter-ami-type').find('.active').length is 2
        isPublic = null

      if $('#filter-ami-32bit-64bit').find('.active').length is 1
        architecture = radiobuttons.data($('#filter-ami-32bit-64bit'))
      else if $('#filter-ami-32bit-64bit').find('.active').length is 2
        architecture = null

      if $('#filter-ami-EBS-Instance').find('.active').length is 1
        rootDeviceType = radiobuttons.data($('#filter-ami-EBS-Instance'))
      else if $('#filter-ami-EBS-Instance').find('.active').length is 2
        rootDeviceType = null
      region  = @workspace.opsModel.get("region")
      perPageNum = parseInt(perPage||50, 10)
      returnPage = parseInt(pageNum, 10)
      renderAmis = (data)=>
        @communityAmiRender(data)
      ApiRequest("aws_public",
        region_name: region
        filters:
          ami: {name, platform, isPublic, architecture, rootDeviceType, perPageNum, returnPage}
      ).then (result)->
        renderAmis(result)
      , (result)->
        notification 'error', lang.ide.RES_MSG_WARN_GET_COMMUNITY_AMI_FAILED
        renderAmis(ami:[])

    searchCommunityAmiPrev: ->
      page = parseInt( $("#community_ami_page_current").attr("page"), 10)
      @searchCommunityAmi(page+1)

    searchCommunityAmiNext: ->
      page = parseInt( $("#community_ami_page_current").attr("page"), 10)
      @searchCommunityAmi(page-1)

    searchCommunityAmiCurrent: (event)->
      if event.keyCode and event.keyCode isnt 13
        return
      @searchCommunityAmi()

    communityAmiRender: (data)->
      @communityShowContent()
      totalNum = 0
      if data.ami
        tpl = ""
        _.each data.ami.result, ( value, key ) ->
          value.favorite = false if value.delete
          fav_class = if value.favorite then 'faved' else ''
          tooltip = if value.favorite then lang.ide.RES_TIT_REMOVE_FROM_FAVORITE else lang.ide.RES_TIT_ADD_TO_FAVORITE
          bit         = if value.architecture == 'i386' then '32' else '64'
          visibility  = if value.isPublic then 'public' else 'private'
          tpl += """
            <tr class="item" data-id="#{key} #{value.name}" data-publicprivate="public" data-platform="#{value.osType}" data-ebs="#{value.rootDeviceType}" data-bit="#{bit}"</tr>
            <td class="ami-table-fav"><div class="toggle-fav tooltip #{fav_class}" data-tooltip="#{tooltip}" data-id="#{key}"></div></td>
            <td class="ami-table-id">#{key}</td>
            <td class="ami-table-info"><span class="ami-table-name">#{value.name}</span><div class="ami-meta"><i class="icon-#{value.osType} icon-ami-os"></i><span>#{visibility} | #{value.architecture} | #{value.rootDeviceType}</span></div></td>
            <td class="ami-table-size">#{value.imageSize}</td></tr>
          """
          true
        $("#community_ami_table").html(tpl)
        currentPageNum = data.ami.curPageNum
        page = "<div>page #{currentPageNum}</div>"
        totalNum = data.ami.totalNum
        totalPageNum = data.ami.totalPageNum
        $("#ami-count").empty().html("Total: #{totalNum}")

        @communityPagerRender currentPageNum, totalPageNum, totalNum

    communityPagerRender: ( current_page, max_page, total ) ->
      resourceView = @
      pageSize = if total > 50 then 50 else total

      itemBegin = ( current_page - 1 ) * 50 + 1
      itemEnd = itemBegin + pageSize - 1
      itemEnd = total if itemEnd > total

      $( '.page-tip' ).text sprintf lang.ide.AMI_LBL_PAGEINFO, itemBegin, itemEnd, total

      pagination = $ '.pagination'

      if max_page is 0
        pagination.hide()
      else
        pagination.show()

      if pagination.data 'jqPagination'
        pagination.jqPagination 'destroy'
        # init page num
        pagination.find( 'input' ).data('current-page', current_page)

      pagination.jqPagination({
        current_page: current_page,
        max_page: max_page,
        page_string: "{current_page} / {max_page}"
        paged: ((current_page, max_page) ->
          (page) ->
            if page isnt current_page and max_page >= page > 0
              resourceView.searchCommunityAmi page
        )(current_page, max_page)

      })


    communityShowContent: () ->
      $( ".show-loading" ).hide()
      $( "#ami-table-wrap .scroll-content" ).show()
      $( "#btn-search-ami" ).text( lang.ide.AMI_LBL_SEARCH ).removeAttr( "disabled" )
      $( "#community-ami-page>div" ).show()

    renderAmiLoading: () ->
      $( "#ami-table-wrap .scroll-content" ).hide()
      $( ".show-loading" ).show()
      $( "#btn-search-ami" ).text( lang.ide.AMI_LBL_SEARCHING ).attr( "disabled", "" )
      $( "#community-ami-page>div" ).hide()
      $("#ami-count").empty().html("Total: 0")

    manageSnapshot : ()-> new snapshotManager().render()

    refreshPanelData : ()->

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
            drop_zone_offset = drop_zone.offset()
            drop_zone_data = {
              'x1' : drop_zone_offset.left
              'x2' : drop_zone_offset.left + drop_zone.width()
              'y1' : drop_zone_offset.top
              'y2' : drop_zone_offset.top + drop_zone.height()
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
