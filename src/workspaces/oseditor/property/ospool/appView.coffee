define [
    'constant'
    '../OsPropertyView'
    '../osport/view'
    '../oshmlist/view'
    './template/app'
    'CloudResources'

], ( constant, OsPropertyView, PortView, HmlistView, template, CloudResources ) ->

    OsPropertyView.extend {
        initialize: ->
            region = Design.instance().region()

            @hmList = _.map @appModel.get( 'health_monitors' ), ( id ) ->
                CloudResources( constant.RESTYPE.OSHM, region ).get id

            @hmlistView = @reg new HmlistView targetModel: @hmList, isApp: true

        render: ->
            @$el.html template @getRenderData()
            @renderHmlist()
            @

        getModelJson: ->
            appJson = @appModel?.toJSON() or {}
            appJson = $.extend( true, {}, appJson )

            PortClass = Design.modelClassForType constant.RESTYPE.OSPORT
            _.each appJson.members, ( m ) ->
                osport = PortClass.find ( port ) -> port.get( 'ip' ) is m.address
                unless osport then return

                m.name = if osport.isEmbedded() then osport.owner().get('name') else osport.get( 'name' )
                null

            appJson

        renderHmlist: -> @$( '.pool-details' ).after @hmlistView.render().el


    }, {
        handleTypes: [ constant.RESTYPE.OSPOOL ]
        handleModes: [ 'app' ]
    }
