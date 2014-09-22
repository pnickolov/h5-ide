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
      @

  }, {
    handleTypes: [ constant.RESTYPE.OSVOL ]
    handleModes: [ 'stack', 'appedit' ]
  }
