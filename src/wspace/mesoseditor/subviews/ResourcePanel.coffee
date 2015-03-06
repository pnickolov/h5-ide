
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

  Backbone.View.extend {

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
      @$el.find('.resource-list-docker-image').html LeftPanelTpl.docker_image(dockerImageCol.toJSON())

    toggleLeftPanel : ()->

      @__leftPanelHidden = @$el.toggleClass("hidden").hasClass("hidden")
      null

    toggleResourcePanel: ()->
      @toggleLeftPanel()

    startDrag : ( evt )->
      if evt.button isnt 0 then return false
      $tgt = $( evt.currentTarget )
      if $tgt.hasClass("disabled") then return false
      if evt.target && $( evt.target ).hasClass("btn-fav-ami") then return

      type = constant.RESTYPE[ $tgt.attr("data-type") ]

      dropTargets = "#OpsEditor .OEPanelCenter"
      if type is constant.RESTYPE.INSTANCE
        dropTargets += ",#changeAmiDropZone"

      option = $.extend true, {}, $tgt.data("option") || {}
      option.type = type

      $tgt.dnd( evt, {
        dropTargets  : $( dropTargets )
        dataTransfer : option
        eventPrefix  : if type is constant.RESTYPE.VOL then "addVol_" else "addItem_"
        onDragStart  : ( data )->
          if type is constant.RESTYPE.AZ
            data.shadow.children(".res-name").text( $tgt.data("option").name )
          else if type is constant.RESTYPE.ASG
            data.shadow.text( "ASG" )
      })
      return false

    remove: ->
      _.invoke @subViews, 'remove'
      @subViews = null
      Backbone.View.prototype.remove.call this
      return

  }
