
define [
  "CloudResources"
  "Design"
  "../template/TplLeftPanel"
  "constant"
  'i18n!/nls/lang.js'
  'ApiRequest'
  'OpsModel'
  "backbone"
  "UI.nanoscroller"
  "UI.dnd"
], ( CloudResources, Design, LeftPanelTpl, constant, lang, ApiRequest, OpsModel )->

  MC.template.resPanelImageDocker = LeftPanelTpl.resourcePanelBubble

  Backbone.View.extend {

    events:

      "mousedown .resource-item" : "startDrag"

    initialize : (options) ->

      _.extend this, options
      @setElement @parent.$el.find(".OEPanelLeft")
      @render()

    render : () ->

      @$el.html LeftPanelTpl.panel()
      @renderDockerImageList()
      @$el.find(".nano").nanoScroller()
      return

    renderDockerImageList : () ->

      dockerImageCol = CloudResources( @workspace.design.credentialId(), constant.RESTYPE.DOCKERIMAGE, @workspace.design.region() )
      dataAry = dockerImageCol.toJSON()
      _.each dataAry, (data) ->
          data.bubble = JSON.stringify(data)
      @$el.find('.resource-list-docker-image').html LeftPanelTpl.docker_image(dataAry)

    toggleLeftPanel : () ->

      @__leftPanelHidden = @$el.toggleClass("hidden").hasClass("hidden")
      null

    toggleResourcePanel: () ->

      @toggleLeftPanel()

    startDrag : ( evt ) ->

      if evt.button isnt 0 then return false
      $tgt = $( evt.currentTarget )

      type = constant.RESTYPE[ $tgt.attr("data-type") ]

      dropTargets = "#OpsEditor .OEPanelCenter"

      option = $.extend true, {}, $tgt.data("option") || {}
      option.type = type

      $tgt.dnd( evt, {
        dropTargets  : $( dropTargets )
        dataTransfer : option
        eventPrefix  : "addItem_"
      })

      return false

    remove: ->

      _.invoke @subViews, 'remove'
      @subViews = null
      Backbone.View.prototype.remove.call this
      return

  }
