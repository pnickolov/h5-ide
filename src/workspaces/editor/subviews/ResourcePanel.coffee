
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
  }
