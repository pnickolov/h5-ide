
define [
    'backbone'
    'constant'
    'CloudResources'
    './template/TplResourcePanel'
    'OsSnapshot'
    'OsKp'

], ( Backbone, constant, CloudResources, ResourcePanelTpl, OsSnapshot, OsKp )->

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
            'mousedown .resource-item'              : 'startDrag'
            'OPTION_CHANGE .ami-type-select'        : 'changeAmiType'
            'click .btn-refresh-panel'              : 'refreshPanelData'
            # 'click .btn-open-shareres'              : 'toggleShareResPanel'
            'click .manage-snapshot'                : 'manageSnapshot'
            'click .resources-dropdown-wrapper li'  : 'resourcesMenuClick'

        amiType: 'public' # public | private

        initialize: ( options ) ->
            _.extend @, options
            region = @workspace.opsModel.get("region")

            @listenTo CloudResources( constant.RESTYPE.OSSNAP, region ), 'update', @renderSnapshot
            @listenTo CloudResources( constant.RESTYPE.OSIMAGE, region ), 'update', @renderAmi

        # toggleShareResPanel: -> @$( 'nav' ).toggleClass 'open'

        resourcesMenuClick : (event) ->
          $currentDom = $(event.currentTarget)
          currentAction = $currentDom.data('action')
          switch currentAction
              when 'keypair'
                  new OsKp().manage()
              when 'snapshot'
                  new OsSnapshot().render()

        changeAmiType: ( event, type ) ->
            @amiType = type
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

        manageSnapshot: ->
          snapshotManager = new OsSnapshot()
          snapshotManager.render()

        renderAmi: ->
            that = @
            region = @workspace.opsModel.get("region")

            amis = CloudResources( constant.RESTYPE.OSIMAGE,  region ).toJSON()
            currentTypeAmis = _.filter amis, ( ami ) -> ami.visibility is that.amiType

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

            option = $.extend true, {}, $tgt.data("option") || {}
            option.type = type

            $tgt.dnd( evt, {
                dropTargets  : $( dropTargets )
                dataTransfer : option
                eventPrefix  : if type is constant.RESTYPE.OSVOL then "addVol_" else "addItem_"
            })
            return false
