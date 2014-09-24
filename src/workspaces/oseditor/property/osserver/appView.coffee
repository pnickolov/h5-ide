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

    events:

        'click .os-server-image-info': 'openImageInfoPanel'

    initialize: ->

        @sgListView = new SgListView {
            panel: @panel,
            targetModel: @model.embedPort()
        }

    render: ->

      @$el.html template.appTemplate @getRenderData()
      # append sglist
      @$el.append @sgListView.render().el
      @

    openImageInfoPanel: ->

      serverData = @getRenderData()
      @showFloatPanel(template.imageTemplate(serverData.system_metadata))

  }, {
    handleTypes: [ constant.RESTYPE.OSSERVER ]
    handleModes: [ 'app' ]
  }
