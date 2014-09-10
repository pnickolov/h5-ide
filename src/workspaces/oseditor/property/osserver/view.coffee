define [
  'constant'
  '../OsPropertyView'
  './template'
  'CloudResources'
  'underscore'
], ( constant, OsPropertyView, template, CloudResources, _ ) ->

  operationArray = [
    "amazon.i386.ebs"
    "amazon.x86_64.ebs"
    "centos.i386.ebs"
    "centos.x86_64.ebs"
    "debian.i386.ebs"
    "debian.x86_64.ebs"
    "fedora.i386.ebs"
    "fedora.x86_64.ebs"
    "gentoo.i386.ebs"
    "gentoo.x86_64.ebs"
    "linux-other.i386.ebs"
    "linux-other.x86_64.ebs"
    "my-ami-o.ebs"
    "my-ami-unk.ebs"
    "my-ami.ebs"
    "opensuse.i386.ebs"
    "opensuse.x86_64.ebs"
    "redhat.i386.ebs"
    "redhat.x86_64.ebs"
    "suse.i386.ebs"
    "suse.x86_64.ebs"
    "ubuntu.i386.ebs"
    "ubuntu.x86_64.ebs"
    "unknown.i386.ebs"
    "unknown.x86_64.ebs"
    "windows.i386.ebs"
    "windows.x86_64.ebs"
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
      console.log template
      json = @model.toJSON()
      json.imageList = CloudResources(constant.RESTYPE.OSIMAGE, Design.instance().region()).toJSON()
      @$el.html template.stackTemplate json
      @bindSelectizeEvent()
      @

    bindSelectizeEvent: ()->
      that = @
      @$el.find("#property-os-server-image").on 'select_initialize', ()->
        that.$el.find("#property-os-server-image")[0].selectize.setValue(that.model.get('image'))

    renderLoadingImageList: ()->
      imageListInstance = @$el.find("#property-os-server-image")[0].selectize
      imageListInstance.setLoading(true)
      imageList = CloudResources constant.RESTYPE.OSIMAGE, Design.instance().region()
      imageList.fetch().then ->
        imageListInstance.setLoading(false)
        imageListInstance.clearOptions()
        _.each imageList.toJSON(), (e)->
          console.log e
          imageListInstance.addOption {value: e.id, text: e.name}
        imageListInstance.$input.off 'select_dropdown_open'
        imageListInstance.refreshOptions()

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

    selectTpl:

      imageItems: (item) ->
        imageList = CloudResources constant.RESTYPE.OSIMAGE, Design.instance().region()
        imageObj = imageList.get(item.value)?.toJSON()
        if not imageObj
          item.distro = "ami-unknown"
          return template.imageListKey(item)

        imageObj.distro = imageObj.os_distro + "." + imageObj.architecture + ".ebs"
        if imageObj.distro not in operationArray
          imageObj.distro = "ami-unknown"
        template.imageListKey(imageObj)

      imageValue: (item) ->
        console.log item
        imageList = CloudResources constant.RESTYPE.OSIMAGE, Design.instance().region()
        imageObj = imageList.get(item.value)?.toJSON()
        if not imageObj
          item.distro = "ami-unknown"
          item.text = item.text || "Unknow"
          return template.imageValue(item)

        imageObj.distro = imageObj.os_distro + "." + imageObj.architecture + ".ebs"
        if imageObj.distro not in operationArray
          imageObj.distro = "ami-unknown"
        template.imageValue(imageObj)

  }, {
    handleTypes: [ constant.RESTYPE.OSSERVER ]
    handleModes: [ 'stack', 'appedit' ]
  }

#  Panel.openProperty({uid:'server0001',type: "OS::Nova::Server"})