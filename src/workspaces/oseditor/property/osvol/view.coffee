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
      mode = Design.instance().mode()
      json = @model.toJSON()
      json.mode = mode
      @$el.html template.stackTemplate json
      if @model.get('snapshot') then @bindSelectizeEvent()
      @
    bindSelectizeEvent: ()->
      that = @
      snapshots = CloudResources(constant.RESTYPE.OSSNAP, Design.instance().region())
      snapshotOptions = _.map snapshots.models, (e)->
        text = e.get('name')
        value = e.get('id')
        {text, value}
      @$el.find("#property-os-volume-snapshot").on 'select_initialize', ()->
        @.selectize.addOption(snapshotOptions)
        @.selectize.setValue(that.model.get('snapshot'))

    selectTpl:
      snapshotOption: (item)->
        snapshots = CloudResources(constant.RESTYPE.OSSNAP, Design.instance().region())
        snapModel = snapshots.get(item.value)
        template.snapshotOption snapModel?.toJSON()

        

  }, {
    handleTypes: [ constant.RESTYPE.OSVOL ]
    handleModes: [ 'stack', 'appedit' ]
  }
