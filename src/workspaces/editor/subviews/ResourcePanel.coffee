
define [ "../template/TplLeftPanel", "backbone" ], ( LeftPanelTpl )->

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

    render : ()->
      @setElement $("#OEPanelLeft").html LeftPanelTpl.panel({})
      $("#OEPanelLeft").toggleClass("hidden", @__rightPanelHidden || false)
      @recalcAccordion()
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
  }
