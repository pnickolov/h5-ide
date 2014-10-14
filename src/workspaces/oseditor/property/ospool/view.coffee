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
                port = mc.getPort()

                json = mc.toJSON()
                json.osport = mc.getPort().toJSON()
                json.osport.name = port.owner().get( 'name' ) if port.isEmbedded()

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

        updateAttribute: (event)->

            model = @getModelForUpdateAttr(event)

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

            if attr in ['weight', 'port']
                model.set('appId', '')

            model.set(attr, value)

            @setTitle(value) if attr is 'name'

    }, {
        handleTypes: [ constant.RESTYPE.OSPOOL ]
        handleModes: [ 'stack', 'appedit' ]
    }
