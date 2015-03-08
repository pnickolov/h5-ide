
define [
  "CloudResources"
  "Design"
  "UI.modalplus"
  "../template/TplLeftPanel"
  "constant"
  'dhcp_manage'
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
  'OpsModel'
  "backbone"
  "UI.nanoscroller"
  "UI.dnd"
], ( CloudResources, Design, Modal, LeftPanelTpl, constant, dhcpManager, EbsSnapshotManager, RdsSnapshotManager, sslCertManager, snsManager, keypairManager,rdsPgManager, rdsSnapshot, AmiBrowser, lang, ApiRequest, OpsModel )->

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

    ami = CloudResources( Design.instance().credentialId(), constant.RESTYPE.AMI, data.region ).get( data.imageId )
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

    ss = CloudResources( Design.instance().credentialId(), constant.RESTYPE.DBSNAP, data.region ).get( data.id )
    if not ss then return

    LeftPanelTpl.resourcePanelBubble( ss.toJSON() )

  MC.template.resPanelSnapshot = ( data )->
    if not data.region or not data.id then return

    ss = CloudResources( Design.instance().credentialId(), constant.RESTYPE.SNAP, data.region ).get( data.id )
    if not ss then return
    newData = {}
    _.each ss.toJSON(), (value, key)->
      newKey = lang.IDE["DASH_BUB_"+ key.toUpperCase()] || key
      newData[newKey] = value
      return
    LeftPanelTpl.resourcePanelBubble( newData )



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
      "click nav button"             : "switchPanel"
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

      'click .apply'                 : 'popApplyMarathonModal'
      'click .container-change'      : 'popApplyMarathonModal'
      'click .container-item'        : 'toggleConstraint'
      'keyup #filter-containers'     : 'filterContainers'
      'change #filter-containers'    : 'filterContainers'
      'click .group-header'          : 'toggleGroup'


    initialize : (options)->
      _.extend this, options

      @subViews = []

      region       = @workspace.design.region()
      credentialId = @workspace.design.credentialId()

      @listenTo CloudResources( credentialId, "MyAmi",               region ), "update", @updateMyAmiList
      @listenTo CloudResources( credentialId, constant.RESTYPE.AZ,   region ), "update", @updateAZ
      @listenTo CloudResources( credentialId, constant.RESTYPE.SNAP, region ), "update", @updateSnapshot
      @listenTo CloudResources( credentialId, constant.RESTYPE.DBSNAP, region ), "update", @updateRDSSnapshotList

      design = @workspace.design
      @listenTo design, Design.EVENT.ChangeResource, @onResChanged
      @listenTo design, Design.EVENT.AddResource,    @updateDisableItems
      @listenTo design, Design.EVENT.RemoveResource, @updateDisableItems
      @listenTo design, Design.EVENT.AddResource,    @updateLc

      @listenTo @workspace, "toggleRdsFeature", @toggleRdsFeature

      @__amiType = "QuickStartAmi" # QuickStartAmi | MyAmi | FavoriteAmi

      @setElement @parent.$el.find(".OEPanelLeft")

      $(document)
        .off('keydown', @bindKey.bind @)
        .on('keydown', @bindKey.bind @)

      @render()

    render : ()->

      hasVGW = hasCGW = true

      if Design.instance().region() is 'cn-north-1'
          hasVGW = hasCGW = false

      @$el.html( LeftPanelTpl.panel({
        rdsDisabled : @workspace.isRdsDisabled(),
        hasVGW: hasVGW,
        hasCGW: hasCGW
      }) )

      @$el.toggleClass("hidden", @__leftPanelHidden || false)
      @recalcAccordion()

      @updateAZ()
      @updateSnapshot()
      @updateAmi()
      @updateRDSList()
      @updateRDSSnapshotList()

      @updateDisableItems()
      @renderReuse()

      @renderContainerList()
      @$el.find(".nano").nanoScroller()

      return

    # For Demo Begin

    switchPanel : (event) ->
      if not event
        @$el.find('.resource-panel').addClass('hide')
        @$el.find('.container-panel').removeClass('hide')
        return
      # clean selected
      $button = $(event.currentTarget)
      $button.parents('nav').find('button').removeClass('selected')
      $button.addClass('selected')

      # switch
      @$el.find('.container-panel').addClass('hide')
      @$el.find('.resource-panel').addClass('hide')
      if $button.hasClass('sidebar-nav-resource')
          @$el.find('.resource-panel').removeClass('hide')
      else
          @$el.find('.container-panel').removeClass('hide')

    popApplyMarathonModal: ->
      data = []
      for model in @workspace.scene.project.stacks().filter((a)-> a.type is OpsModel.Type.Mesos)
        data.push {
          name : model.get("name")
          id   : model.id
        }

      modalOptions =
          template        : MC.template.applyMarathonStack( data )
          title           : 'Apply Marathon Stack '
          confirm         :
              text        : 'Apply'

      @marathonModal = new Modal modalOptions
      @marathonModal.on 'confirm', () ->
        unless $( '#app-usage-selectbox .selected' ).length then return
        @loadMarathon( $( '#app-usage-selectbox .selected' ).attr("data-value") )
        @marathonModal.close()
      , @

    loadMarathon: (opsModelId)->
      that = @
      opsModel = App.model.getOpsModelById( opsModelId )

      data = opsModel.getJsonData()
      if data
        @renderMarathonApp( data )
      else
        opsModel.fetchJsonData().then ()-> that.renderMarathonApp( opsModel.getJsonData() )


    renderMarathonApp: ( data ) ->

      json = $.extend true, {}, data

      # temp hack code
      @marathonJson = json

      $appList = @$ '.marathon-app-list'
      $createPanel = @$ '.create-marathon-panel'

      $appList.show()
      $createPanel.hide()

      @renderContainerList(json)


    toggleConstraint: ( e ) ->

      amimationDuration = 150

      $item = $ e.currentTarget

      @$( '.container-item' ).each ->
        $c = $( @ )
        if $c[0] is $item[0]
          $c.addClass 'selected'
        else
          $c.removeClass 'selected'

      $constraint = $item.next '.constraint-list'

      if $constraint.is(':visible')
        #$constraint.stop().slideUp()
      else
        @$( '.constraint-list' ).each ->
          $c = $( @ )
          if $c.is(':visible') then $c.stop().slideUp(amimationDuration)

        $constraint.stop().slideDown(amimationDuration)

      @highlightCanvas(e)

    highlightCanvas: (event) ->

      # get name -> uid map
      nameMap = {}
      # temp code
      json = Design.instance().serialize()
      _.each json.component, (comp) ->
        nameMap[comp.name] = comp.uid

      # switch highlight
      # qa
      if @marathonJson.name.indexOf('qa') isnt -1
         modelNames1 = ['subne-web-staging-1a', 'subne-web-staging-1b']
         modelNames2 = ['subnet-qa-1a', 'subnet-qa-1b']
         modelNames3 = ['subnet-db-qa-1a', 'subnet-db-qa-1b']
      # prod
      else
         modelNames1 = ['subne-web-prod-1a', 'subnet--web-4prod-1b']
         modelNames2 = ['app-prod-1a-0', 'app-prod-1b-0']
         modelNames3 = ['subnet-db-prod-1a', 'subnet-db-prod-10b']

      if event

          $container = $(event.currentTarget)
          name = $container.data('name')
          if name in ['api-service', 'agent-service', 'nginx']
            modelIds = _.map modelNames1, (name) ->
              return nameMap[name]
          else if name in ['request-master', 'mongos', 'worker', 'resource-diff']
            modelIds = _.map modelNames2, (name) ->
              return nameMap[name]
          else
            modelIds = _.map modelNames3, (name) ->
              return nameMap[name]
          if modelIds
            models = _.map modelIds, (id) ->
              return Design.instance().component(id)
            @workspace.view.highLightModels(models)

    resourceListSortSelectRdsEvent : (event) ->

        selectedId = 'date'

        if event

            $currentTarget = $(event.currentTarget)
            selectedId = $currentTarget.find('.selected').data('id')

        $sortedList = []

        if selectedId is 'date'

            $sortedList = @$el.find('.resource-list-rds-snapshot li').sort (a, b) ->
                return (new Date($(b).data('date'))) - (new Date($(a).data('date')))

        if selectedId is 'engine'

            $sortedList = @$el.find('.resource-list-rds-snapshot li').sort (a, b) ->
                return $(a).data('engine') - $(b).data('engine')

        if selectedId is 'storge'

            $sortedList = @$el.find('.resource-list-rds-snapshot li').sort (a, b) ->
                return Number($(b).data('storge')) - Number($(a).data('storge'))

        if $sortedList.length
            @$el.find('.resource-list-rds-snapshot').html($sortedList)

    resourceListSortSelectSnapshotEvent : (event) ->

        selectedId = 'date'

        if event

            $currentTarget = $(event.currentTarget)
            selectedId = $currentTarget.find('.selected').data('id')

        $sortedList = []

        if selectedId is 'date'

            $sortedList = @$el.find('.resource-list-snapshot li').sort (a, b) ->
                return (new Date($(b).data('date'))) - (new Date($(a).data('date')))

        if selectedId is 'storge'

            $sortedList = @$el.find('.resource-list-snapshot li').sort (a, b) ->
                return Number($(a).data('storge')) - Number($(b).data('storge'))

        if $sortedList.length
            @$el.find('.resource-list-snapshot').html($sortedList)

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

      region = @workspace.design.region()
      usedAZ = ( az.get("name") for az in @workspace.design.componentsOfType(constant.RESTYPE.AZ) || [] )

      availableAZ = []
      for az in CloudResources( @workspace.design.credentialId(), constant.RESTYPE.AZ, region ).where({category:region}) || []
        if usedAZ.indexOf(az.id) is -1
          availableAZ.push(az.id)

      @$el.find(".az").toggleClass("disabled", availableAZ.length is 0).data("option", { name : availableAZ[0] }).children(".resource-count").text( availableAZ.length )
      return

    updateSnapshot : ()->
      region     = @workspace.design.region()
      cln        = CloudResources( @workspace.design.credentialId(), constant.RESTYPE.SNAP, region ).where({category:region}) || []
      cln.region = if cln.length then region else constant.REGION_SHORT_LABEL[region]

      @$el.find(".resource-list-snapshot").html LeftPanelTpl.snapshot( cln )

    toggleRdsFeature : ()->
      @$el.find(".ManageRdsSnapshot").parent().toggleClass( "disableRds", @workspace.isRdsDisabled() )
      if not @workspace.isRdsDisabled()
        @updateRDSList()
        @updateRDSSnapshotList()

      @updateDisableItems()
      @$el.children(".sidebar-title").find(".icon-rds-snap,.icon-pg").toggleClass("disabled", @workspace.isRdsDisabled())
      return

    updateRDSList : () ->
      cln = CloudResources( @workspace.design.credentialId(), constant.RESTYPE.DBENGINE, @workspace.design.region() ).groupBy("DBEngineDescription")
      @$el.find(".resource-list-rds").html LeftPanelTpl.rds( cln )

    updateRDSSnapshotList : () ->
      region     = @workspace.design.region()
      cln        = CloudResources( @workspace.design.credentialId(), constant.RESTYPE.DBSNAP, region ).toJSON()
      cln.region = if cln.length then region else constant.REGION_SHORT_LABEL[region]

      @$el.find(".resource-list-rds-snapshot").html LeftPanelTpl.rds_snapshot( cln )

    changeAmiType : ( evt, attr )->
      @__amiType = attr || "QuickStartAmi"
      @updateAmi()
      if not $(evt.currentTarget).parent().hasClass(".open")
        $(evt.currentTarget).parent().click()
      return

    updateAmi : ()->
      ms = CloudResources( @workspace.design.credentialId(), @__amiType, @workspace.design.region() ).getModels().sort ( a, b )->
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
      if Design.instance().region() in ['cn-north-1']
          minAZCount = 1
      else
          minAZCount = 2
      if _.keys( az ).length < minAZCount
        disabled = true
        tooltip  = sprintf lang.IDE.RES_TIP_DRAG_CREATE_SUBNET_GROUP, minAZCount
        @sbg.toggleClass("disabled", true).attr("data-tooltip", )
      else
        disabled = false
        tooltip = lang.IDE.RES_TIP_DRAG_NEW_SUBNET_GROUP

      if @workspace.isRdsDisabled()
        disabled = true
        tooltip = lang.IDE.RES_MSG_RDS_DISABLED

      @sbg.toggleClass("disabled", disabled).attr("data-tooltip", tooltip)
      return

    updateFavList   : ()-> if @__amiType is "FavoriteAmi" then @updateAmi()
    updateMyAmiList : ()-> if @__amiType is "MyAmi" then @updateAmi()

    toggleFav : ( evt )->
      $tgt = $( evt.currentTarget ).toggleClass("fav")
      amiCln = CloudResources( @workspace.design.credentialId(), "FavoriteAmi", @workspace.design.region() )
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
      region     = @workspace.design.region()
      credential = @workspace.design.credentialId()
      # Start listening fav update.
      @listenTo CloudResources( credential, "FavoriteAmi", region ), "update", @updateFavList

      amiBrowser = new AmiBrowser({ region : region, credential : credential })
      amiBrowser.onClose = ()=>
        @stopListening CloudResources( credential, "FavoriteAmi", region ), "update", @updateFavList
      return false

    manageEbsSnapshot : ()-> new EbsSnapshotManager().render()
    manageRdsSnapshot : ()-> new RdsSnapshotManager().render()

    refreshPanelData : ( evt )->
      $tgt = $( evt.currentTarget ).find(".icon-refresh")
      if $tgt.hasClass("reloading") then return

      $tgt.addClass("reloading")
      region     = @workspace.design.region()
      credential = @workspace.design.credentialId()

      jobs = [
        CloudResources( credential, "MyAmi", region ).fetchForce()
        CloudResources( credential, constant.RESTYPE.SNAP, region ).fetchForce()
      ]

      if @workspace.isRdsDisabled()
        jobs.push @workspace.fetchRdsData()
      else
        jobs.push CloudResources( credential, constant.RESTYPE.DBSNAP, region ).fetchForce()

      Q.all(jobs).done ()-> $tgt.removeClass("reloading")
      return

    resourcesMenuClick : (event) ->
      $currentDom = $(event.currentTarget)
      currentAction = $currentDom.data('action')

      switch currentAction
        when 'keypair'
          manager = keypairManager
        when 'snapshot'
          manager = EbsSnapshotManager
        when 'sns'
          manager = snsManager
        when 'sslcert'
          manager = sslCertManager
        when 'dhcp'
          manager = dhcpManager
        when 'rdspg'
          manager = rdsPgManager
        when 'rdssnapshot'
          manager = rdsSnapshot

      new manager( workspace: @workspace ).render()

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

    renderContainerList: (json) ->

        appMap = {}
        otherApp = []
        dataAry = []

        isApp = Design.instance().mode() is 'app'

        if json and _.keys(json).length > 0

            # analyze app
            _.each json.component, (comp) ->

                if comp.type is constant.RESTYPE.MRTHAPP

                    constraints = _.map comp.resource.constraints, (constraint) ->
                        return constraint.join(', ')

                    name = comp.resource.id
                    task = comp.resource.instances
                    title = 'CONSTRAINTS'
                    instanceTip = 'Instances'

                    if isApp
                        title = 'RUNNING TASKS'
                        constraints = ["mesos-dns.9b85d1a7-c47a-11e4-865f-0ae4c5a555b7", "10.0.0.6:31388"]
                        if name in ['mongodb', 'mongo-config']
                            task = '2/' + task
                            yellow = true
                            instanceTip = 'Tasks/Instances'

                    data = {
                        color: comp.color
                        task: task
                        image: comp.resource.container.docker.image
                        name: name
                        cpu: comp.resource.cpus
                        memory: comp.resource.mem
                        title: title
                        constraints: constraints
                        yellow: yellow
                        instanceTip: instanceTip
                    }
                    appMap[comp.uid] = data

                    otherApp.push(comp.uid)

            # analyze group
            _.each json.component, (comp) ->

                if comp.type is constant.RESTYPE.MRTHGROUP

                    groupId = comp.resource.id
                    appIds = comp.resource.apps
                    apps = _.map appIds, (appId) ->
                        return appMap[appId]
                    dataAry.push({
                        id: groupId
                        apps: apps
                    })
                    otherApp = _.difference(otherApp, appIds)

            otherApp = _.map otherApp, (appId) ->
                return appMap[appId]

            # no group
            if otherApp.length

                dataAry.push({
                    id: "Default"
                    apps: otherApp
                })

            @$('.marathon-app-list').html LeftPanelTpl.containerList({
                project: @workspace.scene.project.id
                id: json.id
                name: json.name
                groups: dataAry
            })

            @recalcAccordion()

    toggleGroup: (event) ->

        $header = $(event.currentTarget)
        $header.toggleClass('expand')
        $container = $header.next '.container-list'
        if $header.hasClass('expand')
            $container.removeClass('hide')
        else
            $container.addClass('hide')

    filterContainers: (evt)->
      keyword = $(evt.currentTarget).val().toLowerCase()
      $(".container-list .container-item").each (index, item)->
        containerName = $(item).data("name").toLowerCase()
        shouldShow =  containerName.indexOf(keyword) >= 0
        if not shouldShow and $(item).hasClass("selected")
          $(item).next().hide()
        $(item).toggle(shouldShow)

  }
