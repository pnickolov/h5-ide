define [
  'constant'
  '../OsPropertyView'
  './template'
], ( constant, OsPropertyView, stackTpl ) ->

  OsPropertyView.extend {
    render: ->
      @$el.html stackTpl(@model.toJSON())
      @

  }, {
    handleTypes: [ constant.RESTYPE.OSSERVER ]
    handleModes: [ 'stack', 'appedit' ]
  }

#  Panel.openProperty({uid:'server0001',type: "OS::Nova::Server"})