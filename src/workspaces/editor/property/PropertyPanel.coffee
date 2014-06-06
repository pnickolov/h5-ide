
define [ "../template/TplRightPanel", "event", "backbone" ], ( RightPanelTpl, ide_event )->

  ide_event.onLongListen ide_event.REFRESH_PROPERTY, ()->
    $("#OEPanelRight").trigger "REFRESH"; return

  ide_event.onLongListen ide_event.FORCE_OPEN_PROPERTY, ()->
    $("#OEPanelRight").trigger "FORCE_SHOW"; return

  ide_event.onLongListen ide_event.SHOW_STATE_EDITOR, (uid)->
    $("OEPanelRight").trigger "SHOW_STATEEDITOR", uid, null, true; return

  ide_event.onLongListen ide_event.OPEN_PROPERTY, ( type, uid, force, tab )->
    $("OEPanelRight").trigger "OPEN", type, uid, force, tab; return


  Backbone.View.extend {

    events :
      "click #HideOEPanelRight"         : "toggleRightPanel"
      "click #hide-second-panel"        : "hideSecondPanel"
      "click .option-group-head"        : "updateRightPanelOption"

      # Events
      "OPEN_SUBPANEL #OEPanelRight"     : "showSecondPanel"
      "HIDE_SUBPANEL #OEPanelRight"     : "immHideSecondPanel"
      "FORCE_SHOW    #OEPanelRight"     : "forceShow"
      "OPEN_SUBPANEL_IMM #OEPanelRight" : "immShowSecondPanel"

      "OPEN    #OEPanelRight"           : "openPanel"
      "REFRESH #OEPanelRight"           : "refreshRightPanel"
      "SHOW_STATEEDITOR #OEPanelRight"  : "showStateEditor"

    render : ()->
      @setElement $("#OEPanelRight").html( RightPanelTpl() )
      $("#OEPanelRight").toggleClass("hidden", @__rightPanelHidden || false)
      return

    toggleRightPanel : ()->
      @__rightPanelHidden = $("#OEPanelRight").toggleClass("hidden").hasClass("hidden")
      false

    showSecondPanel : () ->
      $("#hide-second-panel").data("tooltip", "Back to " + $("#property-title").text())
      $("#property-second-panel").show().animate({left:"0%"}, 200)
      $("#property-first-panel").animate {left:"-30%"}, 200, ()->
        $("#property-first-panel").hide()

    immShowSecondPanel : ()->
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

      if not $('#property-second-panel').is(':hidden') then return

      @__optionStates = @__optionStates || {}

      # added by song ######################################
      # record head state
      comp = @__selectedComp || "stack"
      status = _.map $('#property-first-panel').find('.option-group-head'), ( el )-> $(el).hasClass("expand")
      @__optionStates[ comp ] = status

      comp = @workspace.design.component( comp )
      if comp then @__optionStates[ comp.type ] = status
      # added by song ######################################

      return false

    openPanel : ( type, uid, force, tab )->


    refreshRightPanel : ()->


    showStateEditor : ()->

  }
