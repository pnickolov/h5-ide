define ["CloudResources", 'constant', 'UI.modalplus', 'toolbar_modal', 'i18n!/nls/lang.js', 'component/awscomps/DhcpTpl'], ( CloudResources, constant, modalPlus, toolbarModal, lang, template )->
  fetched = false
  fetching  = false
  regionsMark = {}

  updateAmazonCB = () ->
    rowLength = $( "#property-domain-server" ).children().length
    if rowLength > 3
      $( '#property-amazon-dns' ).attr( "disabled", true )
    else
      $( '#property-amazon-dns' ).removeAttr( "disabled" )

  mapFilterInput = ( selector ) ->
    $inputs = $( selector )
    result  = []

    for ipt in $inputs
      if ipt.value
        result.push ipt.value
    result

  deleteCount = 0
  deleteErrorCount = 0

  DhcpManager = Backbone.View.extend
    constructor:()->
      @collection = CloudResources Design.instance().credentialId(), constant.RESTYPE.DHCP, Design.instance().region()
      @listenTo @collection, 'change', -> @renderManager()
      @listenTo @collection, 'update', -> @renderManager()
      @

    remove: ()->
      @.isRemoved = true
      Backbone.View::remove.call @

    filter: ( keyword ) ->
      hitKeys = _.filter @collection.toJSON(), ( data ) ->
        data.id.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1
      if keyword
        @renderDropdown hitKeys
      else
        @renderDropdown()

    render: ->
      @manager = new toolbarModal @getModalOptions()
      @manager.on 'refresh', @refreshManager, @
      @manager.on 'slidedown', @renderSlides, @
      @manager.on 'action', @doAction, @
      @manager.on 'detail', @detail, @
      @manager.on 'close', =>
        @manager.remove()
      @manager.render()
      @renderManager()
      @.trigger 'manage'

    refreshManager: ->
      fetched = false
      @renderManager()

    renderManager: ->
      if Design.instance().credential()?.isDemo()
        @manager?.render 'nocredential'
        return false
      initManager = @initManager.bind @
      currentRegion = Design.instance()?.get('region')
      if currentRegion and ( (not fetched and not fetching) or (not regionsMark[currentRegion]))
        fetching = true
        regionsMark[currentRegion] = true
        @collection.fetchForce().then initManager, initManager
      else if not fetching
        initManager()

    initManager: ->
      fetching = false
      fetched = true
      content = template.content items:@collection.toJSON()
      @manager?.setContent content

    renderSlides: (which, checked)->
      tpl = template['slide_'+ which]
      slides = @getSlides()
      slides[which]?.call @, tpl, checked

    detail: (event, data, $tr) ->
      dhcpId = data.id
      dhcpData = @collection.get(dhcpId).toJSON()
      detailTpl = template.detail_info
      @manager.setDetail($tr, detailTpl(dhcpData))

    getSlides: ->
      "delete": (tpl, checked)->
        checkedAmount = checked.length
        if not checkedAmount
          return
        data = {}

        if checkedAmount is 1
          data.selectedId = checked[0].data.id
        else
          data.selectedCount = checkedAmount
        @manager.setSlide tpl data

      'create': (tpl)->
        data =
          dhcp: {}

        selectedType = 0
        data.dhcp.netbiosTypes = [
          { id : "default" , value : lang.PROP.VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE_NOT_SPECIFIED, selected : selectedType == 0 }
        , { id : 1 , value : 1, selected : selectedType == 1 }
        , { id : 2 , value : 2, selected : selectedType == 2 }
        , { id : 4 , value : 4, selected : selectedType == 4 }
        , { id : 8 , value : 8, selected : selectedType == 8 }
        ]
        @manager.setSlide tpl data
        @manager.$el.find("#property-amazon-dns").change (e)=> @onChangeAmazonDns(e)
        @manager.$el.find('.multi-input').on 'ADD_ROW',  (e)=> @processParsley(e)
        @manager.$el.find(".control-group .input").change (e)=> @onChangeDhcpOptions(e)
        @manager.$el.find('.formart_toolbar_modal').on 'OPTION_CHANGE REMOVE_ROW', (e)=>@onChangeDhcpOptions(e)
        @manager.$el.find('#property-domain-server').on( 'ADD_ROW REMOVE_ROW', updateAmazonCB )
        updateAmazonCB()

    processParsley: ( event ) ->
      $( event.currentTarget )
      .find( 'input' )
      .last()
      .removeClass( 'parsley-validated' )
      .removeClass( 'parsley-error' )
      .next( '.parsley-error-list' )
      .remove()
      $(".parsley-error-list").remove()

    doAction: (action, checked)->
      @[action] and @[action](@validate(action),checked)

    create: (invalid, checked)->
      if not invalid
        domainNameServers = mapFilterInput "#property-domain-server .input"
        if $("#property-amazon-dns").is(":checked")
          domainNameServers.push("AmazonProvidedDNS")
        data =
          "domain-name"           : mapFilterInput "#property-dhcp-domain .input"
          "domain-name-servers"   : domainNameServers
          "ntp-servers"           : mapFilterInput "#property-ntp-server .input"
          "netbios-name-servers"  : mapFilterInput "#property-netbios-server .input"
          "netbios-node-type"     : [parseInt( $("#property-netbios-type .selection").html(), 10 ) || 0]
        validate = (value, key)->
          if key is 'netbios-node-type'
            return false
          if value.length < 1
            return false
          else
            return true
        if not _.some data, validate
          @manager.error "Please provide at least one field."
          return false
        if data['netbios-node-type'][0] is 0 then data['netbios-node-type'] = []
        @switchAction 'processing'
        afterCreated = @afterCreated.bind @
        @collection.create(data).save().then afterCreated,afterCreated

    delete: (invalid, checked)->
      that = @
      deleteCount += checked.length
      @switchAction 'processing'
      afterDeleted = that.afterDeleted.bind that
      _.each checked, (data)=>
        @collection.findWhere(id: data.data.id).destroy().then afterDeleted, afterDeleted

    afterDeleted: (result)->
      deleteCount--
      if result.error
        deleteErrorCount++
      if deleteCount is 0
        if deleteErrorCount > 0
          notification 'error', sprintf lang.NOTIFY.FAILED_TO_DELETE_DHCP, deleteErrorCount, result.awsResult
        else
          notification 'info', lang.NOTIFY.DELETE_SUCCESSFULLY
        @manager.unCheckSelectAll()
        deleteErrorCount = 0
        @manager.cancel()

    afterCreated: (result)->
      if result.error
        @manager.error "Create failed because of: "+ (result.awsResult || result.msg)
        @switchAction()
        return false
      notification 'info', lang.NOTIFY.DHCP_CREATED_SUCCESSFULLY
      @manager.cancel()

    validate: (action)->
      switch action
        when 'create'
          return @manager.$el.find(".parsley-error").size()>0

    switchAction: ( state ) ->
      if not state
        state = 'init'
      @M$( '.slidebox .action' ).each () ->
        if $(@).hasClass state
          $(@).show()
        else
          $(@).hide()


    onChangeAmazonDns : ->
      useAmazonDns = $("#property-amazon-dns").is(":checked")
      allowRows    = if useAmazonDns then 3 else 4
      $inputbox    = $("#property-domain-server").attr( "data-max-row", allowRows )
      $rows        = $inputbox.children()
      $inputbox.toggleClass "max", $rows.length >= allowRows
      null

    onChangeDhcpOptions : ( event ) ->
      if event and not $( event.currentTarget ).closest( '[data-bind=true]' ).parsley( 'validate' )
        return

    getModalOptions: ->
      that = @
      region = Design.instance().get('region')
      regionName = constant.REGION_SHORT_LABEL[ region ]

      title: sprintf lang.IDE.MANAGE_DHCP_IN_AREA, regionName
      slideable: true
      resourceName:   lang.PROP.RESOURCE_NAME_DHCP
      context: that
      buttons: [
        {
          icon: 'new-stack'
          type: 'create'
          name: lang.PROP.LBL_CREATE_DHCP_OPTIONS_SET
        }
        {
          icon: 'del'
          type: 'delete'
          disabled: true
          name: lang.PROP.LBL_DELETE
        }
        {
          icon: 'refresh'
          type: 'refresh'
          name: ''
        }
      ]
      columns: [
        {
          sortable: true
          width: "200px" # or 40%
          name: lang.PROP.NAME
        }
        {
          sortable: false
          width: "480px" # or 40%
          name: lang.PROP.LBL_OPTIONS
        }
        {
          sortable: false
          width: "56px"
          name: lang.PROP.LBL_DETAIL
        }
      ]

  DhcpManager
