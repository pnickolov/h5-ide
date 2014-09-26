define [
    'constant'
    '../OsPropertyView'
    './template'

], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {

        render: ->
            @$el.html template {
                appId: @model.getResourceId()
            }
            @

    }, {
        handleTypes: [ constant.RESTYPE.OSEXTNET ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }
