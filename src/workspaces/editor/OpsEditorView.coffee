
define [
  "./TplOpsEditor"
  "./TplCanvas"
  "OpsModel"
  "backbone"
  "UI.selectbox"
  "MC.canvas"
], ( OpsEditorTpl, CanvasTpl, OpsModel )->

  # Update Left Panel when window size changes
  __resizeAccdTO = null
  $( window ).on "resize", ()->
    if __resizeAccdTO then clearTimeout(__resizeAccdTO)
    __resizeAccdTO = setTimeout ()->
      $("#OEPanelLeft").trigger("RECALC")
    , 150
    return

  # LEGACY code
  # Should remove this in the future.
  $(document).on('keydown', MC.canvas.event.keyEvent)
  $('#header, #navigation, #tab-bar').on('click', MC.canvas.volume.close)
  $(document.body).on('mousedown', '#instance_volume_list a', MC.canvas.volume.mousedown)


  ### OpsEditorView base class ###
  Backbone.View.extend {
    events :
      "click #HideOEPanelLeft"       : "toggleLeftPanel"
      "OPTION_CHANGE #AmiTypeSelect" : "changeAmiType"
      "click #BrowseCommunityAmi"    : "browseCommunityAmi"
      "click #ManageSnapshot"        : "manageSnapshot"
      "click #RefreshLeftPanel"      : "refreshPanelDataData"
      "click .fixedaccordion-head"   : "updateAccordion"
      "RECALC #OEPanelLeft"          : "recalcAccordion"

      "click #HideOEPanelRight"      : "toggleRightPanel"

    render : ()->
      # 1. Generate basic dom structure.
      tpl = @createTpl()

      console.assert( not @$el or @$el.attr("id") isnt "OpsEditor", "There should be no #OpsEditor when an editor view is rendered." )

      if @$el then @$el.remove()
      @setElement $(tpl).appendTo("#main").show()[0]

      # 2. Bind Events for MC.canvas.js
      @bindUserEvent()

      # 3 Update subviews
      @renderToolbar()

      # 4. OtherSubviews
      @renderSubviews()
      return

    ###
      Override these methods in subclasses.
    ###
    createTpl : ()->
      CanvasTpl({
        noLeftPane   : true
        noBottomPane : true
      })

    bindUserEvent : ()->
      # Events
      $("#canvas_body")
        .addClass("canvas_state_appview")
        .on('mousedown', '.instance-volume, .instanceList-item-volume, .asgList-item-volume', MC.canvas.volume.show)
        .on('mousedown', '.dragable', MC.canvas.event.dragable.mousedown)
        .on('mousedown', '.group-resizer', MC.canvas.event.groupResize.mousedown)
        .on('mouseenter mouseleave', '.node', MC.canvas.event.nodeHover)
        .on('click', '.line', MC.canvas.event.selectLine)
        .on('mousedown', '.AWS-AutoScaling-LaunchConfiguration .instance-number-group', MC.canvas.asgList.show)
        .on('mousedown', MC.canvas.event.clearSelected)
        .on('mousedown', '#svg_canvas', MC.canvas.event.clickBlank)
        .on('mousedown', MC.canvas.event.ctrlMove.mousedown)
        .on('mousedown', '.resource-item', MC.canvas.event.siderbarDrag.mousedown)
        .on('selectstart', false)
      return

    updateTbBtns : ( $toolbar )->
      # LineStyle Btn
      $toolbar.children(".toolbar-line-style").children(".dropdown").children().eq(parseInt(localStorage.getItem("canvas/lineStyle"),10) || 2).click()

      # App Run & Stop
      if @opsModel.isApp()
        $stopBtn = $toolbar.children(".icon-stop")
        if @opsModel.get("stoppable") or not @opsModel.testState( OpsModel.State.Running )
          $stopBtn.hide()
        else
          $stopBtn.show()

        $toolbar.children(".icon-play").toggle( not @opsModel.testState( OpsModel.State.Stopped ) )
      return

    renderSubviews : ()->
      @recalcAccordion()
      return


    ### Internal methods ###
    ### Toolbar Related ###
    renderToolbar : ()->
      # Toolbar
      if @opsModel.isImported()
        btns = ["BtnActionPng", "BtnZoom", "BtnLinestyle"]
      else if @opsModel.isStack()
        btns = ["BtnRunStack", "BtnStackOps", "BtnZoom", "BtnExport", "BtnLinestyle"]
      else
        if @__editMode
          btns = ["BtnApply", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes"]
        else
          btns = ["BtnEditApp", "BtnAppOps", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes"]

      tpl = ""
      for btn in btns
        tpl += OpsEditorTpl.toolbar[ btn ]()

      $toolbar = @$el.children("#OEMiddleWrap").children("#OEPanelTop").html( tpl )

      @updateTbBtns( $toolbar )
      return

    setTbLineStyle : ( ls )->
      localStorage.setItem("canvas/lineStyle", ls)
      $canvas.updateLineStyle( ls )
      return


    ### Resource Panel Related ###
    toggleLeftPanel : ()-> $("#OEPanelLeft").toggleClass("hidden"); false

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


    ### Property Panel Related ###
    toggleRightPanel : ()-> $("#OEPanelRight").toggleClass("hidden"); false

  }
