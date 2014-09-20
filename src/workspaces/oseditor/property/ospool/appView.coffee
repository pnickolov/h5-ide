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

        renderHmlist: -> @$( '.pool-details' ).after @hmlistView.render().el


    }, {
        handleTypes: [ constant.RESTYPE.OSPOOL ]
        handleModes: [ 'app' ]
    }
