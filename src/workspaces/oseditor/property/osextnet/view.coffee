define [
    'constant'
    '../OsPropertyView'
    './template'

], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {

        render: ->
            @$el.html template @model.toJSON()
            @

    }, {
        handleTypes: [ constant.RESTYPE.OSEXTNET ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }