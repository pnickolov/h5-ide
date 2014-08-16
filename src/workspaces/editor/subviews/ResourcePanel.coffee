
define [
  "CloudResources"
  "Design"
  "../template/TplLeftPanel"
  "constant"
  'dhcp'
  'snapshotManager'
  'rds_snapshot'
  'sslcert_manage'
  'sns_manage'
  'kp_manage'
  'rds_pg'
  'rds_snapshot'
  './AmiBrowser'
  'i18n!/nls/lang.js'
  'ApiRequest'
  "backbone"
  'UI.radiobuttons'
  "UI.nanoscroller"
  "UI.dnd"
], ( CloudResources, Design, LeftPanelTpl, constant, dhcpManager, EbsSnapshotManager, RdsSnapshotManager, sslCertManager, snsManager, keypairManager,rdsPgManager, rdsSnapshot, AmiBrowser, lang, ApiRequest )->

  # Update Left Panel when window size changes
  __resizeAccdTO = null
  $( window ).on "resize", ()->
    if __resizeAccdTO then clearTimeout(__resizeAccdTO)
    __resizeAccdTO = setTimeout ()->
      $("#OpsEditor").filter(":visible").children(".OEPanelLeft").trigger("RECALC")
    , 150
    return


  MC.template.resPanelAmiInfo = ( data )->
    if not data.region or not data.imageId then return

    ami = CloudResources( constant.RESTYPE.AMI, data.region ).get( data.imageId )
    if not ami then return

    ami = ami.toJSON()
    ami.imageSize = ami.imageSize || ami.blockDeviceMapping[ami.rootDeviceName]?.volumeSize

    try
      config = App.model.getOsFamilyConfig( data.region )
      config = config[ ami.osFamily ] || config[ constant.OS_TYPE_MAPPING[ami.osType] ]
      config = if ami.rootDeviceType  is "ebs" then config.ebs else config['instance store']
      config = config[ ami.architecture ]
      config = config[ ami.virtualizationType || "paravirtual" ]
      ami.instanceType = config.join(", ")
    catch e

    return MC.template.bubbleAMIInfo( ami )

  MC.template.resPanelDbSnapshot = ( data )->
    if not data.region or not data.id then return

    ss = CloudResources( constant.RESTYPE.DBSNAP, data.region ).get( data.id )
    if not ss then return

    LeftPanelTpl.resourcePanelBubble( ss.toJSON() )

  MC.template.resPanelSnapshot = ( data )->
    if not data.region or not data.id then return

    ss = CloudResources( constant.RESTYPE.SNAP, data.region ).get( data.id )
    if not ss then return

    LeftPanelTpl.resourcePanelBubble( ss.toJSON() )



  LcItemView = Backbone.View.extend {

    tagName   : 'li'
    className : 'resource-item asg'

    initialize: ( options ) ->
      @parent = options.parent
      ( @parent or @ ).$el.find(".resource-list-asg").append @$el

      @listenTo @model, 'change:name', @render
      @listenTo @model, 'change:imageId', @render
      @listenTo @model, 'destroy', @remove

      @render()
      @$el.attr({
        "data-type"   : "ASG"
        "data-option" : '{"lcId":"' + @model.id + '"}'
      })
      return

    render : ()->
      @$el.html LeftPanelTpl.reuse_lc({
        name      : @model.get("name")
        cachedAmi : @model.getAmi() || @model.get("cachedAmi")
      })
  }



  Backbone.View.extend {

    events :
      "click .btn-fav-ami"           : "toggleFav"
      "OPTION_CHANGE .AmiTypeSelect" : "changeAmiType"
      "click .BrowseCommunityAmi"    : "browseCommunityAmi"
      "click .ManageEbsSnapshot"     : "manageEbsSnapshot"
      "click .ManageRdsSnapshot"     : "manageRdsSnapshot"
      "click .fixedaccordion-head"   : "updateAccordion"
      "RECALC"                       : "recalcAccordion"
      "mousedown .resource-item"     : "startDrag"
      "click .refresh-resource-panel": "refreshPanelData"
      'click .resources-dropdown-wrapper li' : 'resourcesMenuClick'

      'OPTION_CHANGE #resource-list-sort-select-snapshot' : 'resourceListSortSelectSnapshotEvent'
      'OPTION_CHANGE #resource-list-sort-select-rds-snapshot' : 'resourceListSortSelectRdsEvent'

    initialize : (options)->
      _.extend this, options

      @subViews = []

      region = @workspace.opsModel.get("region")
      @listenTo CloudResources( "MyAmi",               region ), "update", @updateMyAmiList
      @listenTo CloudResources( constant.RESTYPE.AZ,   region ), "update", @updateAZ
      @listenTo CloudResources( constant.RESTYPE.SNAP, region ), "update", @updateSnapshot
      @listenTo CloudResources( constant.RESTYPE.DBENGINE, region ), "update", @updateRDSList

      design = @workspace.design
      @listenTo design, Design.EVENT.ChangeResource, @onResChanged
      @listenTo design, Design.EVENT.AddResource,    @updateDisableItems
      @listenTo design, Design.EVENT.RemoveResource, @updateDisableItems
      @listenTo design, Design.EVENT.AddResource,    @updateLc

      @__amiType = "QuickStartAmi" # QuickStartAmi | MyAmi | FavoriteAmi

      @setElement @parent.$el.find(".OEPanelLeft")

      $(document)
        .off('keydown', @bindKey.bind @)
        .on('keydown', @bindKey.bind @)

      @render()

    render : ()->

      @$el.html( LeftPanelTpl.panel({}) )

      @$el.toggleClass("hidden", @__leftPanelHidden || false)
      @recalcAccordion()

      @updateAZ()
      @updateSnapshot()
      @updateAmi()
      @updateRDSList()
      @updateRDSSnapshotList()

      @updateDisableItems()
      @renderReuse()

      @$el.find(".nano").nanoScroller()
      return

    resourceListSortSelectRdsEvent : (event) ->

        selectedId = 'date'

        if event

            $currentTarget = $(event.currentTarget)
            selectedId = $currentTarget.find('.selected').data('id')

        $sortedList = []

        if selectedId is 'date'

            $sortedList = @$el.find('.resource-list-rds-snapshot-exist li').sort (a, b) ->
                return (new Date($(b).data('date'))) - (new Date($(a).data('date')))

        if selectedId is 'engine'

            $sortedList = @$el.find('.resource-list-rds-snapshot-exist li').sort (a, b) ->
                return $(a).data('engine') - $(b).data('engine')

        if selectedId is 'storge'

            $sortedList = @$el.find('.resource-list-rds-snapshot-exist li').sort (a, b) ->
                return Number($(b).data('storge')) - Number($(a).data('storge'))

        if $sortedList.length
            @$el.find('.resource-list-rds-snapshot-exist').html($sortedList)

    resourceListSortSelectSnapshotEvent : (event) ->

        selectedId = 'date'

        if event

            $currentTarget = $(event.currentTarget)
            selectedId = $currentTarget.find('.selected').data('id')

        $sortedList = []

        if selectedId is 'date'

            $sortedList = @$el.find('.resource-list-snapshot-exist li').sort (a, b) ->
                return (new Date($(b).data('date'))) - (new Date($(a).data('date')))

        if selectedId is 'storge'

            $sortedList = @$el.find('.resource-list-snapshot-exist li').sort (a, b) ->
                return Number($(a).data('storge')) - Number($(b).data('storge'))

        if $sortedList.length
            @$el.find('.resource-list-snapshot-exist').html($sortedList)

    bindKey: (event)->
      that = this
      keyCode = event.which
      metaKey = event.ctrlKey or event.metaKey
      shiftKey = event.shiftKey
      tagName = event.target.tagName.toLowerCase()
      is_input = tagName is 'input' or tagName is 'textarea'
      # Switch to Resource Pannel [R]
      if metaKey is false and shiftKey is false and keyCode is 82 and is_input is false
        that.toggleResourcePanel()
        return false

    renderReuse: ->
      for lc in @workspace.design.componentsOfType( constant.RESTYPE.LC )
        new LcItemView({model:lc, parent:@}) if not lc.get( 'appId' )
      @

    updateLc : ( resModel ) ->
      if resModel.type is constant.RESTYPE.LC and not resModel.get( 'appId' )
        new LcItemView({model:resModel, parent:@})

    onResChanged : ( resModel )->
      if not resModel then return
      if resModel.type isnt constant.RESTYPE.AZ then return
      @updateAZ()
      return

    updateAZ : ( resModel )->
      if not @workspace.isAwake() then return

      if resModel and resModel.type isnt constant.RESTYPE.AZ then return

      region = @workspace.opsModel.get("region")
      usedAZ = ( az.get("name") for az in @workspace.design.componentsOfType(constant.RESTYPE.AZ) || [] )

      availableAZ = []
      for az in CloudResources( constant.RESTYPE.AZ, region ).where({category:region}) || []
        if usedAZ.indexOf(az.id) is -1
          availableAZ.push(az.id)

      @$el.find(".az").toggleClass("disabled", availableAZ.length is 0).data("option", { name : availableAZ[0] }).children(".resource-count").text( availableAZ.length )
      return

    updateSnapshot : ()->
      region     = @workspace.opsModel.get("region")
      cln        = CloudResources( constant.RESTYPE.SNAP, region ).where({category:region}) || []
      cln.region = region
      if cln and cln.length
        @$el.find(".resource-list-snapshot-exist").html LeftPanelTpl.snapshot( cln )
      else
        @$el.find(".resource-list-snapshot-empty").html LeftPanelTpl.snapshot_empty({regionName: constant.REGION_SHORT_LABEL[region]})

    updateRDSList : () ->
      cln = CloudResources( constant.RESTYPE.DBENGINE, @workspace.opsModel.get("region") ).groupBy("DBEngineDescription")
      @$el.find(".resource-list-rds").html LeftPanelTpl.rds( cln )

    updateRDSSnapshotList : () ->
      region     = @workspace.opsModel.get("region")
      cln        = CloudResources( constant.RESTYPE.DBSNAP, region ).toJSON()
      cln.region = region
      if cln and cln.length
        @$el.find(".resource-list-rds-snapshot-exist").html LeftPanelTpl.rds_snapshot( cln )
      else
        @$el.find(".resource-list-rds-snapshot-empty").html LeftPanelTpl.rds_snapshot_empty({regionName: constant.REGION_SHORT_LABEL[region]})

    changeAmiType : ( evt, attr )->
      @__amiType = attr || "QuickStartAmi"
      @updateAmi()
      if not $(evt.currentTarget).parent().hasClass(".open")
        $(evt.currentTarget).parent().click()
      return

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

      ms.fav    = @__amiType is "FavoriteAmi"
      ms.region = @workspace.opsModel.get("region")

      html = LeftPanelTpl.ami ms
      @$el.find(".resource-list-ami").html(html).parent().nanoScroller("reset")

    updateDisableItems : ( resModel )->
      if not @workspace.isAwake() then return
      @updateAZ( resModel )

      design  = @workspace.design
      RESTYPE = constant.RESTYPE

      # VPC related
      $ul = @$el.find(".resource-item.igw").parent()
      $ul.children(".resource-item.igw").toggleClass("disabled", design.componentsOfType(RESTYPE.IGW).length > 0)
      $ul.children(".resource-item.vgw").toggleClass("disabled", design.componentsOfType(RESTYPE.VGW).length > 0)

      # Subnet group
      az = {}
      for subnet in design.componentsOfType(RESTYPE.SUBNET)
        az[ subnet.parent().get("name") ] = true

      @sbg = @$el.find(".resource-item.subnetgroup")
      if _.keys( az ).length < 2
        @sbg.toggleClass("disabled", true).data("tooltip", "To create subnet group, there must to be subnets from at least 2 different availability zones on canvas.")
      else
        @sbg.toggleClass("disabled", false).data("tooltip", lang.ide.RES_TIP_DRAG_NEW_SUBNET_GROUP)
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

    browseCommunityAmi : ()->
      region = @workspace.opsModel.get("region")
      # Start listening fav update.
      @listenTo CloudResources( "FavoriteAmi", region ), "update", @updateFavList

      amiBrowser = new AmiBrowser({ region : region })
      amiBrowser.onClose = ()=>
        @stopListening CloudResources( "FavoriteAmi", region ), "update", @updateFavList
      return false

    manageEbsSnapshot : ()-> new EbsSnapshotManager().render()
    manageRdsSnapshot: ()->new RdsSnapshotManager().render()

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
                  new EbsSnapshotManager().render()
              when 'sns'
                  new snsManager().render()
              when 'sslcert'
                  new sslCertManager().render()
              when 'dhcp'
                  (new dhcpManager()).manageDhcp()
              when 'rdspg'
                  new rdsPgManager().render()
              when 'rdssnapshot'
                  new rdsSnapshot().render()

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
            data.shadow.children(".res-name").text( $tgt.data("option")["name"] )
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
