define [
    'constant'
    '../OsPropertyView'
    '../osport/view'
    './template/app'


], ( constant, OsPropertyView, portView, template ) ->

    OsPropertyView.extend {

        render: ->
            @$el.html template @getRenderData()
            @


    }, {
        handleTypes: [ constant.RESTYPE.OSLISTENER ]
        handleModes: [ 'app' ]
    }
