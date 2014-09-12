define [
  'constant'
  '../OsPropertyView'
  './template'
  'CloudResources'
  'underscore'
], ( constant, OsPropertyView, template, CloudResources, _ ) ->

  osDistroArray = [
    'amazon'
    'centos'
    'debian'
    'fedora'
    'gentoo'
    'linux-other'
    'opensuse'
    'redhat'
    'suse'
    'ubuntu'
    'unknown'
    'windows'
  ]
  OsPropertyView.extend {
    events:
      "change #property-os-server-credential": "onChangeCredential"
      "change #property-os-server-name": "updateServerAttr"
      "change #property-os-server-image": "updateServerAttr"
      "change #property-os-server-CPU":  "updateServerAttr"
      "change #property-os-server-RAM": "updateServerAttr"
      "change #property-os-server-keypair": "updateServerAttr"
      "change #property-os-server-adminPass": "updateServerAttr"
      "change #property-os-server-userdata": "updateServerAttr"
      'change #property-os-server-fip': "updateServerAttr"
      'change #property-os-server-aip': "updateServerAttr"


    render: ->
      json = @model.toJSON()
      @flavorList = CloudResources(constant.RESTYPE.OSFLAVOR, Design.instance().region())
      @kpList = CloudResources(constant.RESTYPE.OSKP, Design.instance().region())
      window.a = CloudResources( constant.RESTYPE.OSKP, Design.instance().region())
      flavorGroup = _.groupBy @flavorList.toJSON(), 'vcpus'
      currentFlavor = @flavorList.get(@model.get('flavorId')) || _.first @flavorList.models
      json.kpList = @kpList.toJSON()
      json.flavorGroup = flavorGroup
      json.avaliableRams = _.map ( _.pluck flavorGroup[currentFlavor.get('vcpus')], 'ram'), (e)-> {text: e/1024, value: e}
      json.imageList = CloudResources(constant.RESTYPE.OSIMAGE, Design.instance().region()).toJSON()
      json.ram = currentFlavor.get('ram')
      json.vcpus = currentFlavor.get('vcpus')
      console.log json

      @$el.html template.stackTemplate json
      @bindSelectizeEvent()
      @

    bindSelectizeEvent: ()->
      that = @
      @$el.find("#property-os-server-image").on 'select_initialize', ()->
        that.$el.find("#property-os-server-image")[0].selectize.setValue(that.model.get('imageId'))

    onChangeCredential: (event)->
      result = $(event.currentTarget)
      @model.set('credential', result.getValue())
      if result.getValue() is "keypair"
        @$el.find("#property-os-server-keypair").parent().show()
        @$el.find('#property-os-server-adminPass').parent().hide()
      else
        @$el.find("#property-os-server-keypair").parent().hide()
        @$el.find('#property-os-server-adminPass').parent().show()

    updateServerAttr: (event)->
      console.log event
      target = $(event.currentTarget)
      attr = target.data('target')

      if attr is 'imageId'
        @model.setImage target.val()

      if attr is 'name'
        @setTitle target.val()

      if attr is 'CPU'
        flavorGroup = _.groupBy @flavorList.models, (e)-> return e.get 'vcpus'
        availableRams = flavorGroup[target.val()]
        console.log availableRams
        if availableRams?.length
          ramSelectize = @$el.find("#property-os-server-RAM")[0].selectize
          ramValue = ramSelectize.getValue()
          availableRamsValue = _.map (_.pluck (_.map availableRams, (ram)-> ram.toJSON()), 'ram'), (e)-> {text: (e/1024 + " G"), value: e}
          currentRamFlavor = _.find(availableRams, (e)-> return e.get('ram') is +ramValue)
          if not currentRamFlavor
            ramValue = _.min(_.pluck availableRamsValue, 'value')
            currentRamFlavor = _.find(availableRams, (e)-> return e.get('ram') is +ramValue)
          @model.set("flavorId", currentRamFlavor.get('id'))
          @updateRamOptions(availableRamsValue, ramValue)
          console.log currentRamFlavor.get('id')
        else
          return false
        return false

      if attr is 'RAM'
        oldRamFlavor = @flavorList.get @model.get('flavorId')
        flavorGroup = _.groupBy @flavorList.models, (e)-> e.get 'vcpus'
        availableRams = flavorGroup[oldRamFlavor.get('vcpus')]
        targetFlavor = _.find availableRams, (e)->return e.get('ram') is +target.val()
        @model.set('flavorId', targetFlavor.get('id'))
        return false

      if attr is "fixedIp"
        serverPort = @model.embedPort()
        serverPort.updateFip(target.val())
        return false

      if attr is 'associateFip'
        serverPort = @model.embedPort()
        serverPort.set('associateFip', target.val())
        return false

      @model.set(attr, target.val()) if attr

    updateRamOptions: (availableRams, currentRam)->
      ramSelection = @$el.find("#property-os-server-RAM")[0].selectize
      ramSelection.clearOptions()
      ramSelection.load (callback)->
        console.log currentRam
        callback availableRams
        ramSelection.refreshOptions(false)
        ramSelection.setValue(currentRam)


    selectTpl:

      imageItems: (item) ->
        imageList = CloudResources constant.RESTYPE.OSIMAGE, Design.instance().region()
        imageObj = imageList.get(item.value)?.toJSON()
        if not imageObj
          item.distro = "ami-unknown"
          return template.imageListKey(item)

        if imageObj.os_distro not in osDistroArray
          imageObj.os_distro = "unknown"
        imageObj.distro = imageObj.os_distro + "." + imageObj.architecture
        template.imageListKey(imageObj)

      imageValue: (item) ->
        console.log item
        imageList = CloudResources constant.RESTYPE.OSIMAGE, Design.instance().region()
        imageObj = imageList.get(item.value)?.toJSON()
        if not imageObj
          item.distro = "ami-unknown"
          item.text = item.text || "Unknow"
          return template.imageValue(item)

        if imageObj.os_distro not in osDistroArray
          imageObj.os_distro = "unknown"
        imageObj.distro = imageObj.os_distro + "." + imageObj.architecture
        template.imageValue(imageObj)

  }, {
    handleTypes: [ constant.RESTYPE.OSSERVER ]
    handleModes: [ 'stack', 'appedit' ]
  }

#  Panel.openProperty({uid:'server0001',type: "OS::Nova::Server"})