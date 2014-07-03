
define [
  "../template/TplRightPanel"
  "../property/base/main"
  'component/stateeditor/stateeditor'
  "constant"
  "Design"
  "OpsModel"
  "event"
  'CloudResources'
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

], ( RightPanelTpl, PropertyBaseModule, stateeditor, CONST, Design, OpsModel, ide_event, CloudResources )->

  ide_event.onLongListen ide_event.REFRESH_PROPERTY, ()->
    $("#OEPanelRight").trigger "REFRESH"; return

  ide_event.onLongListen ide_event.FORCE_OPEN_PROPERTY, ()->
    $("#OEPanelRight").trigger "FORCE_SHOW"
    $("#OEPanelRight").trigger "SHOW_PROPERTY"
    return

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
      "click .HideOEPanelRight"  : "toggleRightPanel"
      "click .HideSecondPanel"   : "hideSecondPanel"
      "click .option-group-head" : "updateRightPanelOption"

      # Events
      "OPEN_SUBPANEL"     : trimmedJqEventHandler("showSecondPanel")
      "HIDE_SUBPANEL"     : trimmedJqEventHandler("immHideSecondPanel")
      "OPEN_SUBPANEL_IMM" : trimmedJqEventHandler("immShowSecondPanel")
      "OPEN"              : trimmedJqEventHandler("openPanel")
      "SHOW_STATEEDITOR"  : "showStateEditor"
      "FORCE_SHOW"        : "forceShow"
      "REFRESH"           : "refresh"

      "SHOW_PROPERTY"              : "switchToProperty"
      "click #btn-switch-property" : "switchToProperty"
      "click #btn-switch-state"    : "showStateEditor"

    render : ()->
      @setElement @workspace.view.$el.find(".OEPanelRight").html( RightPanelTpl() )
      @$el.toggleClass("hidden", @__rightPanelHidden || false)

      if @__backup
        PropertyBaseModule.restore( @__backup )
        @restoreAccordion( @__backup.activeModuleType, @__backup.activeModuleId )
      else
        @openPanel()

      if @__showingState
        @showStateEditor()
      return

    backup : ()->
      @$el.empty().attr("id", "")
      @__backup = PropertyBaseModule.snapshot()
      return

    recover : ()->
      @$el.attr("id", "OEPanelRight")
      @render()
      return

    toggleRightPanel : ()->
      @__rightPanelHidden = @$el.toggleClass("hidden").hasClass("hidden")
      false

    showSecondPanel : ( type, id ) ->
      @$el.find(".HideSecondPanel").data("tooltip", "Back to " + @$el.find(".property-title").text())
      @$el.find(".property-second-panel").show().animate({left:"0%"}, 200)
      @$el.find(".property-first-panel").animate {left:"-30%"}, 200, ()=>
        @$el.find(".property-first-panel").hide()

    immShowSecondPanel : ( type , id )->
      @$el.find(".HideSecondPanel").data("tooltip", "Back to " + @$el.find(".property-title").text())
      @$el.find(".property-second-panel").show().css({left:"0%"})
      @$el.find(".property-first-panel").css({left:"-30%",display:"none"})
      null

    immHideSecondPanel : () ->
      @$el.find(".property-second-panel").css({
        display : "none"
        left    : "100%"
      }).children(".scroll-wrap").children(".property-content").empty()

      @$el.find(".property-first-panel").css {
        display : "block"
        left    : "0px"
      }
      null

    hideSecondPanel : () ->
      $panel = @$el.find(".property-second-panel")
      $panel.animate {left:"100%"}, 200, ()=> @$el.find(".property-second-panel").hide()
      @$el.find(".property-first-panel").show().animate {left:"0%"}, 200

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

      if not $toggle.parents(".property-first-panel").length then return

      @__optionStates = @__optionStates || {}

      # added by song ######################################
      # record head state
      comp = PropertyBaseModule.activeModule().uid || "Stack"
      status = _.map @$el.find('.property-first-panel').find('.option-group-head'), ( el )-> $(el).hasClass("expand")
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
          type = component.type || 'Missing_Resource'
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
      @restoreAccordion( type , uid )

      # Update state switcher
      @updateStateSwitcher( type, uid )

      @$el.toggleClass("state", false)
      @__showingState = false
      return

    restoreAccordion : ( type, uid )->
      if not @__optionStates then return
      states = @__optionStates[ uid ]
      if not states then states = @__optionStates[ type ]
      if states
        for el, idx in @$el.find('.property-first-panel').find('.option-group-head')
          $(el).toggleClass("expand", states[idx])

        for uid, states of @__optionStates
          if not uid or @workspace.design.component( uid ) or uid.indexOf("i-") is 0 or uid is "Stack"
            continue
          delete @__optionStates[ uid ]
      return


    updateStateSwitcher : ( type, uid )->
      supports = false
      design   = @workspace.design

      if type is "component_server_group" or type is CONST.RESTYPE.LC or type is CONST.RESTYPE.INSTANCE
        if Design.instance().attributes.agent.enabled
          supports = true
        else
          supports = false
        if design.modeIsApp()
          if type is "component_server_group"
            supports = false
          if type is CONST.RESTYPE.LC
            supports = @workspace.opsModel.testState( OpsModel.State.Stopped )

      @$el.toggleClass( "no-state", not supports )
      if supports
        count = design.component( uid ) or design.component(PropertyBaseModule.activeModule().model.attributes.uid)
        count = count?.get("state")?.length or 0
        $( '#btn-switch-state' ).find("b").text "(#{count})"
      supports

    forceShow : ()->
      if @__rightPanelHidden
        @__rightPanelHidden = false
        @$el.toggleClass("no-transition", true).removeClass("hidden")
        self = @
        setTimeout ()->
          self.$el.removeClass("no-transition")
        , 100
      return

    refresh : ()->
      active = PropertyBaseModule.activeModule() || {}
      @openPanel( active.handle, active.uid )
      return

    switchToProperty : ()->
      # if not @__showingState then return
      @__showingState = false
      @$el.toggleClass("state", false)
      @refresh()
      return

    showStateEditor : ( jqueryEvent, uid )->
      if jqueryEvent?.type is "SHOW_STATEEDITOR" and @__showingState
        return false
      if not uid then uid = PropertyBaseModule.activeModule().uid
      design = @workspace.design
      comp   = design.component( uid ) or CloudResources(CONST.RESTYPE.INSTANCE, Design.instance().get('region')).findWhere(id: uid)?.attributes
      if not comp then return
      if not comp.type then comp.type = CONST.RESTYPE.INSTANCE

      if not @updateStateSwitcher( comp.type, uid )
        @openPanel( comp.type, uid )
        return

      @__showingState = true
      @$el.toggleClass("state", true)

      if design.modeIsApp()
        uid   = Design.modelClassForType(CONST.RESTYPE.INSTANCE).getEffectiveId(uid).uid

      allCompData = design.serialize().component
      compData    = allCompData[uid]
      stateeditor.loadModule(allCompData, uid)

      @forceShow()
      return
  }
