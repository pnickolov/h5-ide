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


    render: ->
      json = @model.toJSON()
      flavorList = CloudResources(constant.RESTYPE.OSFLAVOR, Design.instance().region())

      flavorGroup = _.groupBy flavorList.toJSON(), 'vcpus'
      currentFlavor = flavorList.get(@model.get('flavor_id'))

      json.flavorGroup = flavorGroup
      json.avaliableRams = _.map ( _.pluck flavorGroup[currentFlavor.get('vcpus')], 'ram'), (e)-> Math.round(e/1024)
      json.imageList = CloudResources(constant.RESTYPE.OSIMAGE, Design.instance().region()).toJSON()
      json.ram = Math.round(currentFlavor.get('ram')/1024)
      json.vcpus = currentFlavor.get('vcpus')
      @$el.html template.stackTemplate json
      @bindSelectizeEvent()
      @

    bindSelectizeEvent: ()->
      that = @
      @$el.find("#property-os-server-image").on 'select_initialize', ()->
        that.$el.find("#property-os-server-image")[0].selectize.setValue(that.model.get('image'))
      window.a = CloudResources constant.RESTYPE.OSFLAVOR, Design.instance().region()

    onChangeCredential: (event)->
      result = $(event.currentTarget)
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
      @model.set(attr, target.val()) if attr

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