
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

    amiType = 'public' # public | private

    Backbone.View.extend

        events:
            'mousedown .resource-item'          : 'startDrag'
            'OPTION_CHANGE .ami-type-select'    : 'changeAmiType'
            'click .btn-refresh-panel'          : 'refreshPanelData'

        initialize: ( options ) ->
            _.extend @, options
            region = @workspace.opsModel.get("region")
            window.snapshot = CloudResources( constant.RESTYPE.OSSNAP, region )
            window.ami = CloudResources( constant.RESTYPE.OSIMAGE, region )

            @listenTo CloudResources( constant.RESTYPE.OSSNAP, region ), 'update', @renderSnapshot
            @listenTo CloudResources( constant.RESTYPE.OSIMAGE, region ), 'update', @renderAmi

        changeAmiType: ( event, type ) ->
            amiType = type
            @renderAmi()

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
            currentTypeAmis = _.filter amis, ( ami ) -> ami.visibility is amiType

            data = _.map currentTypeAmis, ( ami ) -> _.extend { region: region }, ami

            @$( '.resource-list-ami' ).html ResourcePanelTpl.ami data
            @

        refreshPanelData : ( evt )->
            $tgt = $( evt.currentTarget )
            if $tgt.hasClass("reloading") then return

            $tgt.addClass("reloading")
            region = @workspace.opsModel.get("region")

            jobs = [
                CloudResources( constant.RESTYPE.OSIMAGE, region ).fetchForce()
                CloudResources( constant.RESTYPE.OSSNAP,  region ).fetchForce()
            ]

            Q.all(jobs).done ()-> $tgt.removeClass("reloading")
            return

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


