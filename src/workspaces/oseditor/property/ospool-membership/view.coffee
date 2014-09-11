define [
  'constant'
  '../OsPropertyView'
  './template'

], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {
        render: ->
            poolName = @model.getTarget( constant.RESTYPE.OSPOOL ).get 'name'
            memberName = @model.getOtherTarget( constant.RESTYPE.OSPOOL ).get 'name'

            @$el.html template { poolName: poolName, memberName: memberName }
            @

    }, {
        handleTypes: [ 'OsPoolMembership' ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }