define [
  'constant'
  '../OsPropertyView'
  './template'
], ( constant, OsPropertyView, stackTpl ) ->

  OsPropertyView.extend {
    events:
      "change #property-os-server-credential": "onChangeCredential"

    render: ->
      @$el.html stackTpl(@model.toJSON())
      @

    onChangeCredential: (event)->
      result = $(event.currentTarget)
      if result.getValue() is "keypair"
        @$el.find("#property-os-server-keypair").parent().show()
        @$el.find('#property-os-server-adminPass').parent().hide()
      else
        @$el.find("#property-os-server-keypair").parent().hide()
        @$el.find('#property-os-server-adminPass').parent().show()

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