define [
  'combo_dropdown'
  'UI.modalplus'
  'component/awscomps/EipManageTpl'
  'constant'
  'backbone'
  'CloudResources'
  'eip_manager'
  'i18n!/nls/lang.js'
  'UI.notification'
], (comboDropdown, Modal, template, constant, Backbone, CloudResources, EipManager, lang) ->
  Backbone.View.extend {
    initialize: (@model)->
      @collection = CloudResources Design.instance().credentialId(), constant.RESTYPE.EIP, Design.instance().get("region")
      @listenTo @collection, 'change', @renderDropdown
      @listenTo @collection, 'update', @renderDropdown
      @listenTo Design.instance().credential(), "update", @credChanged
      @listenTo Design.instance().credential(), "change", @credChanged
      @renderModal()

    renderModal: ()->
      self = @
      @modal = new Modal {
        title: "Please Select a eip to assign"
        template: template.selector
        confirm: lang.PROP.EIP_SELECTOR_CONFIRM_LABEL
      }
      @modal.on "shown", ()->
        self.renderDropdown()

      @modal.on "confirm", ()->
        if self.selected
          self.model.setPrimaryEip(true, self.selectedEip)
          self.trigger "assign"
          self.modal.close()
        else
          self.modal.find("#need-select-eip").removeClass("hide")

    credChanged: ()->
      @dropdown?.render("loading")
      @collection.fetchForce().then =>
        @renderDropdown()

    renderDropdown: ()->
      option =
        manageBtnValue: lang.PROP.EIP_DROPDOWN_MANAGE
        filterPlaceHolder: lang.PROP.EIP_DROPDOWN_FILTER
        resourceName: lang.PROP.EIP_RESOURCE_NAME
      @dropdown = new comboDropdown option
      selection = lang.PROP.SELECT_EIP_SELECTION
      @dropdown.setSelection selection
      @dropdown.on 'open', @renderEip , @
      @dropdown.on 'manage', @manageEip, @
      @dropdown.on 'change', @assignEip, @
      @dropdown.on 'filter', @filter, @
      if not Design.instance().credential() or Design.instance().credential().isDemo()
        @dropdown.render('nocredential').toggleControls false
      @modal.tpl.find("#eip-selector").html @dropdown.$el

    renderEip: (keySet)->
      self = @
      @collection.fetch().then ()->
        data = self.collection.toJSON()
        currentRegion = Design.instance().region()
        if keySet
          data = keySet
        enisWithEip = _.filter Design.instance().componentsOfType(constant.RESTYPE.ENI), (eni)->
          eni.hasPrimaryEip()
        usedEips = _.map enisWithEip, (eni)->
          return eni.get("ips")[0].eipData.publicIp
        data = _.filter data, (eip)->
          if eip.publicIp in usedEips
            return false
          eip.category is currentRegion and eip.canRelease
        dataSet =
          data: data
        if keySet
          dataSet.hideNewEip = true

        if self.selected
          selected = null
          if self.selectedEip and self.selectedEip.id
            selected = self.selectedEip.id
          else
            selected = self.selectedEip
          dataSet.selected = selected

        currentEip = null
        if self.model.getEmbedEni
          currentEip = self.model.getEmbedEni().getCurrentEip()
        else
          currentEip = self.model.getCurrentEip()
        if currentEip
          dataSet.currentEip = {id: currentEip.resource.PublicIp}
          # dataSet.hideNewEip = true
        content = template.dropdown dataSet
        self.dropdown.toggleControls true, "manage"
        self.dropdown.toggleControls true, "filter"
        self.dropdown.setContent content
      console.log "Render Eip List"

    manageEip: ()->
      console.log("Show Eip Manager")
      new EipManager( workspace: @workspace ).render()

    assignEip: (id)->
      eip = @collection.find {id: id}
      eip ||= id
      @selected = true
      @selectedEip = eip
      @modal.find("#need-select-eip").addClass("hide")
      console.log "Assign Elastic Ip to Model"
      console.log eip

    filter: (keyword)->
      console.log("Filter Elastic Ip")
      hitKeys = _.filter @collection.toJSON(), (eip)->
        eip.id.toLowerCase().indexOf(keyword.toLowerCase()) isnt -1
      if keyword
        @renderEip(hitKeys)
      else
        @renderEip()

  }