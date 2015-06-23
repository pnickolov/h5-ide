define [
  'toolbar_modal'
  'UI.modalplus'
  'component/awscomps/EipManageTpl'
  'constant'
  'backbone'
  'CloudResources'
  'i18n!/nls/lang.js'
  'UI.notification'
], (toolbar_modal, modalplus, template, constant, Backbone, CloudResources, lang) ->
  Backbone.View.extend

    initialize: (options) ->
      _.extend @, options

      @collection = CloudResources Design.instance().credentialId(), constant.RESTYPE.EIP, Design.instance().get("region")
      @initModal()
      @modal.render()

      if Design.instance().credential() and not Design.instance().credential().isDemo()
        that = @
        @collection.fetch().then ->
          that.renderKeys()
      else
        @modal.render 'nocredential'

      @collection.on 'update', @renderKeys, @
      @listenTo Design.instance().credential(), "update", @credChanged
      @listenTo Design.instance().credential(), "change", @credChanged

    initModal: () ->
      new toolbar_modal @getModalOptions()
      @modal.on 'close', () ->
        @remove()
      , @
      @modal.on 'slidedown', @renderSlides, @
      @modal.on 'action', @doAction, @
      @modal.on 'refresh', @refresh, @

    credChanged: ()->
      @collection.fetchForce()
      @modal.renderLoading()
      @modal and @refresh()

    renderKeys: () ->
      if not @collection.isReady()
        return false
      data = keys: _.filter @collection.toJSON(), (eip)->
        eip.category is Design.instance().region()
      @modal.setContent template.keys data
      @

    doAction: (action, checked) ->
      @[action] and @[action](@validate(action), checked)

    validate: (action) ->
      switch action
        when 'create'
          return false

    switchAction: (state) ->
      if not state
        state = 'init'

      @M$('.slidebox .action').each () ->
        if $(@).hasClass state
          $(@).show()
        else
          $(@).hide()

    genDeleteFinish: (times) ->
      success = []
      error = []
      that = @

      finHandler = _.after times, ->
        that.cancel()
        if success.length is 1
          console.debug success
          notification 'info', sprintf lang.NOTIFY.EIP_XXX_IS_RELEASED, success[0].attributes.id
          return
        else if success.length > 1
          notification 'info', sprintf lang.NOTIFY.SELECTED_EIP_ARE_DELETED, success.length
          return

        if not that.collection.toJSON().length
          that.M$('#t-m-select-all')
          .get(0)
          .checked = false

        _.each error, (s) ->
          console.log(s)
        if error.length > 0
          notification 'error', lang.NOTIFY.FAILED_TO_RELEASE_EIP

      (res) ->
        console.debug res
        if not (res.reason || res.msg)
          success.push res
        else
          error.push res

        finHandler()

    create: (invalid) ->
      that = @
      if not invalid
        domain = "vpc"
        region = Design.instance().region()
        @switchAction 'processing'
        @collection.create({domain, region}).save()
        .then (res) ->
          notification "info", sprintf lang.NOTIFY.EIP_XXX_IS_CREATED, res.attributes.id
          that.cancel()
        , (err) ->
          that.modal.error err.awsResult or err.reason or err.msg
          that.switchAction()

    delete: (invalid, checked) ->
      count = checked.length

      onDeleteFinish = @genDeleteFinish count
      @switchAction 'processing'
      that = @
      _.each checked, (c) =>
        @collection.findWhere(publicIp: c.data.name.toString()).destroy().then onDeleteFinish, onDeleteFinish

    cancel: ->
      @modal.cancel()

    refresh: ->
      @modal?.render "loading"
      @collection.fetchForce().then =>
        @renderKeys()

    renderSlides: (which, checked) ->
      tpl = template["slide_#{which}"]
      slides = @getSlides()
      slides[which]?.call @, tpl, checked


    getSlides: ->
      that = @
      modal = @modal

      create: (tpl) ->
        modal.setSlide tpl

      "delete": (tpl, checked) ->
        checkedAmount = checked.length

        if not checkedAmount
          return

        data = {}

        if checkedAmount is 1
          data.selecteEip = checked[0].data.name
        else
          data.selectedCount = checkedAmount

        modal.setSlide tpl data

    getModalOptions: ->
      that = @
      region = Design.instance().get('region')
      regionName = constant.REGION_SHORT_LABEL[region]

      title: sprintf lang.IDE.MANAGE_EIP_IN_AREA, regionName
      resourceName: lang.PROP.RESOURCE_NAME_EIP
      context: that
      buttons: [
        {
          icon: 'new-stack'
          type: 'create'
          name: lang.IDE.COMPONENT_CREATE_EIP
        }
        {
          icon: 'del'
          type: 'delete'
          disabled: true
          name: lang.IDE.COMPONENT_DELETE_EIP
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
          width: "35%" # or 40%
          name: "Elastic IP"
        }
        {
          width: "15%"
          sortable: true
          name: "Instance"
        }
        {
          width: "15%"
          sortable: true
          name: "Private IP"
        }
        {
          width: "15%"
          sortable: true
          name: "Domain"
        }
        {
          width: "15%"
          sortable: true
          name: "Network Interface"
        }
      ]
