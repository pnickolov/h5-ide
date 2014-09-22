define [
  'constant'
  '../OsPropertyView'
  './template'
  'CloudResources'
], ( constant, OsPropertyView, template, CloudResources ) ->

  OsPropertyView.extend {

    render: ->
      console.log @getRenderData()
      @$el.html template.appTemplate @getRenderData()
      @

  }, {
    handleTypes: [ constant.RESTYPE.OSVOL ]
    handleModes: [ 'app' ]
  }
