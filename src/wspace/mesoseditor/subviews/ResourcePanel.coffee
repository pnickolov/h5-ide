
define [
  "CloudResources"
  "Design"
  "../template/TplLeftPanel"
  "constant"
  'i18n!/nls/lang.js'
  'ApiRequest'
  'OpsModel'
  "backbone"
  "UI.nanoscroller"
  "UI.dnd"
], ( CloudResources, Design, LeftPanelTpl, constant, lang, ApiRequest, OpsModel )->

  Backbone.View.extend {

    events:

      "RECALC" : "recalcAccordion"

    initialize : (options) ->

      _.extend this, options
      @setElement @parent.$el.find(".OEPanelLeft")
      @render()

    render : () ->

      @$el.html LeftPanelTpl.panel()
      @recalcAccordion()
      @$el.find(".nano").nanoScroller()
      return

    toggleLeftPanel : ()->

      @__leftPanelHidden = @$el.toggleClass("hidden").hasClass("hidden")
      null

    toggleResourcePanel: ()->
      @toggleLeftPanel()

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
        $accordion.addClass("expanded").children(".nano").nanoScroller("reset")
        $expanded.removeClass("expanded")
        return false

      $body.slideDown 200, ()->
        $accordion.addClass("expanded").children(".nano").nanoScroller("reset")

      $expanded.children(".accordion-body").slideUp 200, ()->
        $expanded.closest(".accordion-group").removeClass("expanded")
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

    startDrag : ( evt )->
      if evt.button isnt 0 then return false
      $tgt = $( evt.currentTarget )
      if $tgt.hasClass("disabled") then return false
      if evt.target && $( evt.target ).hasClass("btn-fav-ami") then return

      type = constant.RESTYPE[ $tgt.attr("data-type") ]

      dropTargets = "#OpsEditor .OEPanelCenter"
      if type is constant.RESTYPE.INSTANCE
        dropTargets += ",#changeAmiDropZone"

      option = $.extend true, {}, $tgt.data("option") || {}
      option.type = type

      $tgt.dnd( evt, {
        dropTargets  : $( dropTargets )
        dataTransfer : option
        eventPrefix  : if type is constant.RESTYPE.VOL then "addVol_" else "addItem_"
        onDragStart  : ( data )->
          if type is constant.RESTYPE.AZ
            data.shadow.children(".res-name").text( $tgt.data("option").name )
          else if type is constant.RESTYPE.ASG
            data.shadow.text( "ASG" )
      })
      return false

    remove: ->
      _.invoke @subViews, 'remove'
      @subViews = null
      Backbone.View.prototype.remove.call this
      return

  }
