define [
  'constant'
  '../OsPropertyView'
  './template'
  'CloudResources'
  'underscore'
  'OsKp'
], ( constant, OsPropertyView, template, CloudResources, _, OsKp ) ->

  OsPropertyView.extend {
    render: ->
      console.log @model
      @$el.html template.stackTemplate @model.toJSON()
      @

  }, {
    handleTypes: [ constant.RESTYPE.OSRT ]
    handleModes: [ 'stack', 'appedit' ]
  }