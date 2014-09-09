define [
  'constant'
  '../OsPropertyView'
  './template'
], ( constant, OsPropertyView, stackTpl ) ->

  OsPropertyView.extend {
    render: ->
      @$el.html stackTpl(@model.toJSON())
      @

    selectTpl:

      imageItems: (item) ->
        return '<div><img class="property-os-image-icon" src="/assets/images/ide/ami/'+item.value+'" alt=""/><p class="property-os-image-text">' + item.text + '<span>'+item.value+'</span></p></div>'

      imageValue: (item) ->
        return '<div><img src="/assets/images/ide/ami/'+item.value+'" alt=""/>' + item.text + '</div>'

  }, {
    handleTypes: [ constant.RESTYPE.OSSERVER ]
    handleModes: [ 'stack', 'appedit' ]
  }

#  Panel.openProperty({uid:'server0001',type: "OS::Nova::Server"})