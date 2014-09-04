
define [
    'backbone'
    'constant'
    './template/TplResourcePanel'

], ( Backbone, constant, ResourcePanelTpl )->

  Backbone.View.extend

    events:
        'mousedown .resource-item'   : 'startDrag'

    initialize: ( options ) ->

    render: () ->
        @$el.html ResourcePanelTpl {}
        @

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
                    data.shadow.children(".res-name").text( $tgt.data("option")["name"] )
                else if type is constant.RESTYPE.ASG
                    data.shadow.text( "ASG" )
          })
        return false


