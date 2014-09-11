define [
  'constant'
  '../OsPropertyView'
  './template'

], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {
        events:
            'change #property-os-listener-name': 'updateAttribute'
            'change #property-os-listener-limit': 'updateAttribute'
            'change #property-os-listener-protocol': 'updateAttribute'
            'change #property-os-listener-port': 'updateAttribute'

        render: ->
            @$el.html template @model.toJSON()
            @

        updateAttribute: ( e )->
            $target = $ e.currentTarget
            attr = $target.data 'target'

            unless attr then return
            value = $target.val()
            @model.set(attr, value)

            if attr is 'name' then @setTitle value

    }, {
        handleTypes: [ constant.RESTYPE.OSLISTENER ]
        handleModes: [ 'stack', 'appedit' ]
    }