define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    'UI.selection'
], ( constant, OsPropertyView, template, CloudResources, bindSelection ) ->

    OsPropertyView.extend {

        events:
            "change [data-target]": "updateAttribute"

        setTitle: ( title ) -> @$( 'h1' ).text title

        render: ->
            bindSelection(@$el, @selectTpl)
            @$el.html template @model.toJSON()
            @


    }, {
        handleTypes: [ constant.RESTYPE.OSHM ]
        handleModes: [ 'stack', 'appedit' ]
    }
