define [
  'constant'
  '../OsPropertyView'
  './stack'

], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {
        events:
            'change [data-target]': 'updateAttribute'

        initialize: ->
            @hm = @model.getHm()
            @memConn = @model.connections 'OsPoolMembership'

        render: ->
            data = @model.toJSON()
            data.hm = @hm.toJSON()
            data.mems = _.map @memConn, ( mc ) ->
                json = mc.toJSON()
                json.osport = mc.getPort().toJSON()
                json

            @$el.html template data
            @

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