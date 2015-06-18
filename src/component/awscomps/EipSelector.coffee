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
      @renderModal()

    renderModal: ()->
      self = @
      @modal = new Modal {
        title: "Please Select a eip to assign"
        template: template.selector
      }
      @modal.on "shown", ()->
        dropdown = self.renderDropdown()
        self.modal.tpl.find("#eip-selector").html dropdown.$el

      @modal.on "confirm", ()->
        if self.selected
          self.model.setPrimaryEip(true, self.selectedEip)
          self.trigger "assign"
          self.modal.close()
        else
          self.modal.find("#need-select-eip").removeClass("hide")

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
      @selected = true
      @selectedEip = eip
      @modal.find("#need-select-eip").addClass("hide")
      console.log "Assign Elastic Ip to Model"
      console.log eip
#      @model.setPrimaryEip(true, eip)

    filter: (keyword)->
      console.log("Filter Elastic Ip")
      hitKeys = _.filter @collection.toJSON(), (eip)->
        eip.id.toLowerCase().indexOf(keyword.toLowerCase()) isnt -1
      if keyword
        @renderEip(hitKeys)
      else
        @renderEip()

  }