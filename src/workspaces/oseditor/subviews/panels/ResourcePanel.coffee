
define [
    'backbone'
    'constant'
    'CloudResources'
    './template/TplResourcePanel'

], ( Backbone, constant, CloudResources, ResourcePanelTpl )->

    MC.template.resPanelOsAmiInfo = ( data ) ->
        if not data.region or not data.imageId then return

        ami = CloudResources( constant.RESTYPE.OSIMAGE, data.region ).get( data.imageId )

        MC.template.bubbleOsAmiInfo( ami?.toJSON() or {} )

    MC.template.resPanelOsSnapshot = ( data ) ->
        if not data.region or not data.id then return

        snapshot = CloudResources( constant.RESTYPE.OSSNAP, data.region ).get( data.id )

        MC.template.bubbleOsSnapshotInfo( snapshot?.toJSON() or {} )


    Backbone.View.extend

        events:
            'mousedown .resource-item'   : 'startDrag'

        initialize: ( options ) ->
            _.extend @, options
            region = @workspace.opsModel.get("region")
            window.snapshot = CloudResources( constant.RESTYPE.OSSNAP, region )

            @listenTo CloudResources( constant.RESTYPE.OSSNAP, region ), 'update', @renderSnapshot
            @listenTo CloudResources( constant.RESTYPE.OSIMAGE, region ), 'update', @renderAmi

        render: () ->
            @$el.html ResourcePanelTpl.frame {}

            @renderAmi()
            @renderSnapshot()

            @

        renderSnapshot: ->
            region = @workspace.opsModel.get("region")

            snapshots = CloudResources( constant.RESTYPE.OSSNAP, region ).toJSON()
            data = _.map snapshots, ( ss ) -> _.extend { region: region }, ss

            @$( '.resource-list-volume' ).html ResourcePanelTpl.snapshot data
            @

        renderAmi: ->
            region = @workspace.opsModel.get("region")

            amis = CloudResources( constant.RESTYPE.OSIMAGE,  region ).toJSON()
            data = _.map amis, ( ami ) -> _.extend { region: region }, ami

            @$( '.resource-list-ami' ).html ResourcePanelTpl.ami data
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


