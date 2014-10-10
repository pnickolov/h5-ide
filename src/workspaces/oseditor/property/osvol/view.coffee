define [
  'constant'
  '../OsPropertyView'
  './template'
  'CloudResources'
], ( constant, OsPropertyView, template, CloudResources ) ->

  OsPropertyView.extend {

    events:
      "change [data-target]": "updateAttribute"

    render: ->

      @$el.html template.stackTemplate @getRenderData()
      if @model.get('snapshot') then @bindSelectizeEvent()
      @

    bindSelectizeEvent: ()->
      that = @
      @snapshots ||= CloudResources(constant.RESTYPE.OSSNAP, Design.instance().region())
      snapshotOptions = _.map @snapshots.models, (e)->
        text = e.get('name')
        value = e.get('id')
        {text, value}
      snapshotSelectElem = @$el.find("#property-os-volume-snapshot")
      snapshotSelectElem.on 'select_initialize', ()->
        @.selectize.addOption(snapshotOptions)
        @.selectize.setValue(that.model.get('snapshot'))
      sizeInputElement = @$el.find("#property-os-volume-size")
      snapshotSelectElem.on 'change', ()->
        _.defer -> sizeInputElement.val(that.model.get('size'))

    updateAttribute: (event)->
      OsPropertyView::updateAttribute.apply(@, arguments)
      targetDom = event.currentTarget || event.target
      if $(targetDom).data('target') is "snapshot"
        volumeSize = @snapshots.get($(targetDom).val()).get('size')
        @model.set('size', volumeSize)

    selectTpl:
      snapshotOption: (item)->
        snapshots = CloudResources(constant.RESTYPE.OSSNAP, Design.instance().region())
        snapModel = snapshots.get(item.value)
        template.snapshotOption snapModel?.toJSON()

  }, {
    handleTypes: [ constant.RESTYPE.OSVOL ]
    handleModes: [ 'stack', 'appedit' ]
  }
