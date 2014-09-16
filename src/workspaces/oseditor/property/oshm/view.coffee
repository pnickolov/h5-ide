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

        initialize: (options) ->

        render: ->
            bindSelection(@$el, @selectTpl)
            @$el.html template @model.toJSON()
            @


    }, {
        handleTypes: [ constant.RESTYPE.OSHM ]
        handleModes: [ 'stack', 'appedit' ]
    }
