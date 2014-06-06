
define [
  "../template/TplRightPanel"
  "../property/base/main"
  'component/stateeditor/stateeditor'
  "constant"
  "Design"
  "OpsModel"
  "event"
  "backbone"

  '../property/stack/main'
  '../property/instance/main'
  '../property/servergroup/main'
  '../property/connection/main'
  '../property/staticsub/main'
  '../property/missing/main'
  '../property/sg/main'
  '../property/sgrule/main'
  '../property/volume/main'
  '../property/elb/main'
  '../property/az/main'
  '../property/subnet/main'
  '../property/vpc/main'
  '../property/rtb/main'
  '../property/static/main'
  '../property/cgw/main'
  '../property/vpn/main'
  '../property/eni/main'
  '../property/acl/main'
  '../property/launchconfig/main'
  '../property/asg/main'

], ( RightPanelTpl, PropertyBaseModule, stateeditor, CONST, Design, OpsModel, ide_event )->

  ide_event.onLongListen ide_event.REFRESH_PROPERTY, ()->
    $("#OEPanelRight").trigger "REFRESH"; return

  ide_event.onLongListen ide_event.FORCE_OPEN_PROPERTY, ()->
    $("#OEPanelRight").trigger "FORCE_SHOW"; return

  ide_event.onLongListen ide_event.SHOW_STATE_EDITOR, (uid)->
    $("#OEPanelRight").trigger "SHOW_STATEEDITOR", [uid]; return

  ide_event.onLongListen ide_event.OPEN_PROPERTY, ( type, uid )->
    $("#OEPanelRight").trigger "OPEN", [type, uid]; return

  trimmedJqEventHandler = ( funcName )->
    ()->
      trim = Array.prototype.slice.call arguments, 0
      trim.shift()
      @[funcName].apply @, trim


  Backbone.View.extend {

    events :
      "click #HideOEPanelRight"         : "toggleRightPanel"
      "click #hide-second-panel"        : "hideSecondPanel"
      "click .option-group-head"        : "updateRightPanelOption"

      # Events
      "OPEN_SUBPANEL"     : trimmedJqEventHandler("showSecondPanel")
      "HIDE_SUBPANEL"     : trimmedJqEventHandler("immHideSecondPanel")
      "OPEN_SUBPANEL_IMM" : trimmedJqEventHandler("immShowSecondPanel")
      "OPEN"              : trimmedJqEventHandler("openPanel")
      "SHOW_STATEEDITOR"  : "showStateEditor"
      "FORCE_SHOW"        : "forceShow"
      "REFRESH"           : "refresh"

      "click #btn-switch-property" : "switchToProperty"
      "click #btn-switch-state"    : "showStateEditor"

    render : ()->
      @setElement $("#OEPanelRight").html( RightPanelTpl() )
      $("#OEPanelRight").toggleClass("hidden", @__rightPanelHidden || false)

      if @__backup
        PropertyBaseModule.restore( @__backup )
      else
        @openPanel()

      if @__showingState
        @showStateEditor()
      return

    clearDom : ()->
      @$el = null
      @__backup = PropertyBaseModule.snapshot()
      return


    toggleRightPanel : ()->
      @__rightPanelHidden = $("#OEPanelRight").toggleClass("hidden").hasClass("hidden")
      $( '#status-bar-modal' ).toggleClass 'toggle', @__rightPanelHidden
      false

    showSecondPanel : ( type, id ) ->
      $("#hide-second-panel").data("tooltip", "Back to " + $("#property-title").text())
      $("#property-second-panel").show().animate({left:"0%"}, 200)
      $("#property-first-panel").animate {left:"-30%"}, 200, ()->
        $("#property-first-panel").hide()

    immShowSecondPanel : ( type , id )->
      $("#hide-second-panel").data("tooltip", "Back to " + $("#property-title").text())
      $("#property-second-panel").show().css({left:"0%"})
      $("#property-first-panel").css({left:"-30%",display:"none"})
      null

    immHideSecondPanel : () ->
      $("#property-second-panel").css({
        display : "none"
        left    : "100%"
      }).children(".scroll-wrap").children(".property-content").empty()

      $("#property-first-panel").css {
        display : "block"
        left    : "0px"
      }
      null

    hideSecondPanel : () ->
      $panel = $("#property-second-panel")
      $panel.animate {left:"100%"}, 200, ()->
        $("#property-second-panel").hide()
      $("#property-first-panel").show().animate {left:"0%"}, 200

      PropertyBaseModule.onUnloadSubPanel()
      false

    updateRightPanelOption : ( event ) ->
      $toggle = $(event.currentTarget)

      if $toggle.is("button") or $toggle.is("a") then return

      hide    = $toggle.hasClass("expand")
      $target = $toggle.next()

      if hide
          $target.css("display", "block").slideUp(200)
      else
          $target.slideDown(200)
      $toggle.toggleClass("expand")

      if not $toggle.parents("#property-first-panel").length then return

      @__optionStates = @__optionStates || {}

      # added by song ######################################
      # record head state
      comp = PropertyBaseModule.activeModule().uid || "Stack"
      status = _.map $('#property-first-panel').find('.option-group-head'), ( el )-> $(el).hasClass("expand")
      @__optionStates[ comp ] = status

      comp = @workspace.design.component( comp )
      if comp then @__optionStates[ comp.type ] = status
      # added by song ######################################

      return false

    openPanel : ( type, uid )->

      if @__lastOpenType is type and @__lastOpenId is uid and @__showingState
        return

      @__lastOpenType = type
      @__lastOpenId   = uid

      # Blur any focused input
      # Better than $("input:focus")
      $(document.activeElement).filter("input, textarea").blur()

      @immHideSecondPanel()

      # Load property
      # Format `type` so that PropertyBaseModule knows about it.
      # Here, type can be : ( according to the previous version of property/main )
      # - "component_asg_volume"   => Volume Property
      # - "component_asg_instance" => Instance main
      # - "component"
      # - "stack"

      design = @workspace.design
      if not design then return

      # If type is "component", type should be changed to ResourceModel's type
      if uid
        component = design.component( uid )
        if component and component.type is type and design.modeIsApp() and component.get( 'appId' ) and not component.hasAppResource()
          type = 'Missing_Resource'
      else
        type = "Stack"


      # Get current model of design
      if design.modeIsApp() or design.modeIsAppView()
        tab_type = PropertyBaseModule.TYPE.App

      else if design.modeIsStack()
        tab_type = PropertyBaseModule.TYPE.Stack

      else
        # If component has associated aws resource (a.k.a has appId), it's AppEdit mode ( Partially Editable )
        # Otherwise, it's Stack mode ( Fully Editable )
        if not component or component.get("appId")
          tab_type = PropertyBaseModule.TYPE.AppEdit
        else
          tab_type = PropertyBaseModule.TYPE.Stack


      # Tell `PropertyBaseModule` to load corresponding property panel.
      try
        PropertyBaseModule.load type, uid, tab_type
        ### env:prod ###
      catch error
        console.error error
        ### env:prod:end ###
      finally

      # Restore accordion
      if @__optionStates
        states = @__optionStates[ uid ]
        if not states then states = @__optionStates[ type ]
        if states
          for el, idx in $('#property-first-panel').find('.option-group-head')
            $(el).toggleClass("expand", states[idx])

          for uid, states of @__optionStates
            if not uid or design.component( uid ) or uid.indexOf("i-") is 0 or uid is "Stack"
              continue
            delete @__optionStates[ uid ]

      # Update state switcher
      @updateStateSwitcher( type, uid )

      $("#OEPanelRight").toggleClass("state", false)
      return

    updateStateSwitcher : ( type, uid )->
      supports = false
      design   = @workspace.design

      if type is "component_server_group" or type is CONST.RESTYPE.LC or type is CONST.RESTYPE.INSTANCE
        supports = true
        if design.modeIsApp()
          if type is "component_server_group"
            supports = false
          if type is CONST.RESTYPE.LC
            supports = @workspace.opsModel.testState( OpsModel.State.Stopped )

      $("#OEPanelRight").toggleClass( "no-state", not supports )
      if supports
        count = design.component( uid )
        count = count?.get("state") or 0
        $( '#btn-switch-state' ).find("b").text "(#{count})"
      supports

    forceShow : ()->
      if @__rightPanelHidden
        $("#HideOEPanelRight").click()
      return

    refresh : ()->
      active = PropertyBaseModule.activeModule() || {}
      @openPanel( active.handle, active.uid )
      return

    switchToProperty : ()->
      # if not @__showingState then return
      @__showingState = false
      $("#OEPanelRight").toggleClass("state", false)
      @refresh()
      return

    showStateEditor : ( jqueryEvent, uid )->
      if not uid then uid = PropertyBaseModule.activeModule().uid
      design = @workspace.design
      comp   = design.component( uid )
      if not comp then return

      if not @updateStateSwitcher( comp.type, uid )
        @openPanel( comp.type, uid )
        return

      @__showingState = true
      $("#OEPanelRight").toggleClass("state", true)

      if design.modeIsApp()
        resId = uid
        uid   = Design.modelClassForType(CONST.RESTYPE.INSTANCE).getEffectiveId(uid).uid


      allCompData = design.serialize().component
      compData    = allCompData[uid]
      stateeditor.loadModule(allCompData, uid, resId)

      @forceShow()
      return
  }
