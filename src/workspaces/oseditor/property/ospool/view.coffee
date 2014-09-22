define [
  'constant'
  '../OsPropertyView'
  './template/stack'
  '../oshmlist/view'

], ( constant, OsPropertyView, template, HmlistView ) ->

    OsPropertyView.extend {
        events:
            'change [data-target]': 'updateAttribute'

        initialize: ->
            @memConn = @model.connections 'OsPoolMembership'
            @hmlistView = @reg new HmlistView targetModel: @model

        render: ->
            @$el.html template @getRenderData()
            @renderHmlist()

            @

        getModelJson: ->
            data = OsPropertyView.prototype.getModelJson.call @
            data.mems = _.map @memConn, ( mc ) ->
                json = mc.toJSON()
                json.osport = mc.getPort().toJSON()
                json
            data

        renderHmlist: -> @$( '.pool-details' ).after @hmlistView.render().el

        getModelForUpdateAttr: ( e ) ->
            $target = $ e.currentTarget
            dataModel = $target.data( 'model' )
            unless dataModel then dataModel = $target.closest( '[data-model]' ).data 'model'

            switch dataModel
                when 'hm' then return @hm
                when 'mem' then return @memConn[ $target.data( 'index' ) ]
                else return @model


    }, {
        handleTypes: [ constant.RESTYPE.OSPOOL ]
        handleModes: [ 'stack', 'appedit' ]
    }