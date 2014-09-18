define [
  'constant'
  '../OsPropertyView'
  './template'
  'CloudResources'
  'underscore'
  'OsKp'
  '../ossglist/view'
], ( constant, OsPropertyView, template, CloudResources, _, OsKp, SgListView ) ->

  OsPropertyView.extend {


    initialize: ->

        @sgListView = new SgListView {
            panel: @panel,
            targetModel: @model.embedPort()
        }

    render: ->
      json = @model.toJSON()
      @$el.html template.appTemplate json
      # append sglist
      @$el.append @sgListView.render().el
      @

  }, {
    handleTypes: [ constant.RESTYPE.OSSERVER ]
    handleModes: [ 'app' ]
  }

#  Panel.openProperty({uid:'server0001',type: "OS::Nova::Server"})
